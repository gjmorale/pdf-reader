module FileMeta

=begin
	module FileMeta::Map
		NOT_FOUND = "Banco no encontrado".freeze
		FULL = [
			["BC",/Acrobat PDFWriter 5\.0 para Windows NT/, /Aplicaci.+n Mantenedores ADC - \[Procesos de Cierre\]/],
			["BC",/Apache FOP Version 1\.0/, /Apache FOP Version 1\.0/],
			["BC",/Mac OS X 10\.10\.2 Quartz PDFContext/, /Apache FOP Version 1\.0/],
			["BC",/GPL Ghostscript 9\.05/, /PDFCreator Version 1\.5\.1/],
			["BC",/GPL Ghostscript 9\.10/, /PDFCreator Version 1\.7\.3/],
			["CrediCorp",/Mac OS X 10\.10\.2 Quartz PDFContext/, /wkhtmltopdf 0\.12\.3\.1/],
			["CrediCorp",/modified using iTextSharp/, /wkhtmltopdf 0\.12\.3\.1/],
			["CrediCorp",/Mac OS X 10\.10\.2 Quartz PDFContext/, /wkhtmltopdf 0\.12\.3\.1/],
			["CrediCorp",/Qt 4\.8\.7"/, /wkhtmltopdf 0\.12\.3\.1/],
			["HSBC",/Actuate XML to PDF Converter 1\.0/, /Actuate/],
			["MON", /ComponentOne PDF Generator 8.0/,/^$/],
			["MS",//, /Morgan Stanley/i],
			["PER",/303l Linux \(64bit\)/, /Ricoh Production Print Solutions Afp2Pdf Version: 303l/],
			["SEC",/Adobe LiveCycle Output 8\.2/, /Adobe LiveCycle Output 8\.2/],
			["SEC",/Mac OS X 10\.10\.2 Quartz PDFContext/, /Adobe LiveCycle Output 8\.2/]
		]
		IGNORE = [
			["MS",/PDFlib 7\.0\.4p3 \(zSeries USS\)/, /Designer 11\.0\.13 Build: 181/],
			["CITI",/Mac OS X 10\.10\.2 Quartz PDFContext/, /Papyrus Server/],
			["CITI",/"PDFium"/, /"PDFium"/],
			["CITI",/Mac OS X 10\.10\.2 Quartz PDFContext/, /PDFium/],
			["CITI",/"iText 2\.1\.0 \(by lowagie\.com\)"/, /^$/],
			["EA",/iText 2\.1\.7 by 1T3XT/, /JasperReports \(InfoCarteraMasterPag1_H\)/],
			["LV",/Powered By Crystal/, /Crystal Reports/],
			["LV",/Mac OS X 10\.10\.2 Quartz PDFContext/, /Crystal Reports/],
			["LV",/iTextSharp 4\.1\.2 \(based on iText 2\.1\.2u\)/, /^$/],
			["LV",/Mac OS X 10\.10\.2 Quartz PDFContext/, /^$/],
			["LV",/iText 2\.1\.7 by 1T3XT/, /JasperReports Library version 5\.6\.1/],
			["LV",/Mac OS X 10\.10\.2 Quartz PDFContext/, /JasperReports Library version 5\.6\.1/],
			["LV",/Toolkit http:\/\/www\.activepdf\.com/, /Toolkit http:\/\/www\.activepdf\.com/],
			["LV",/Mac OS X 10\.10\.2 Quartz PDFContext/, /PaperPort 12/],
			["LV",/Mac OS X 10\.10\.2 Quartz PDFContext/, /Toolkit http:\/\/www\.activepdf\.com/],
			["MBI",/iTextSharp.+ 5\.4\.1 .+2000-2012 1T3XT BVBA \(AGPL-version\)/, /^$/],
			["MBI",/phpToPDF\.com/, /phpToPDF\.com/],
			["MBI",/Mac OS X 10\.10\.2 Quartz PDFContext/, /phpToPDF\.com/],
			["BTG",/iText 2\.1\.7 by 1T3XT/, /JasperReports \(OnlineNormal\)/],
			["FIDELITY",/303m z\/OS USS \(64bit\)/, /Ricoh Production Print Solutions Afp2Pdf Version: 303m/],
			["BICE",/Stimulsoft Reports/, /Stimulsoft Reports 2013\.1\.1600 from 2 April 2013/],
			["SANTANDER",/aspEasyPDF 3\.30 http:\/\/www\.mitdata\.com/, /^$/],
			["BCI",/GPL Ghostscript 9\.04/, /PDFCreator Version 1\.2\.3/]
		]
		CONFLICT = [
			[
				[
					["SEC",/VALORES SECURITY/],
					["BC",/BANCHILE/],
					["BCI",/BCI/]
				],
			/.*/, /.*/]
		]
	end
=end

	def self.classify_files files
		files_out = []
		files.each.with_index do |file, i|
			attrs = FileMeta.classify file
			puts "[#{i+1}/#{files.size}]#{attrs[:file_name]}"
			next if Statement.find_by(file_hash: attrs[:file_hash])
			statement = Statement.new(attrs)
			files_out << statement if statement.save
			puts statement.errors.inspect
		end
		files_out
	end

	def self.classify file
		attrs = {}
		attrs[:file_name] = File.basename(file,'.pdf')
		attrs[:path] = file.gsub(Paths::DROPBOX,'')
		attrs[:file_hash] = Digest::MD5.file(file).hexdigest
		client = File.dirname file
		client = Society.find_by(name: client[client.rindex('/')+1..-1])
		attrs[:client_id] = client.id if client
		correct_file file do |reader|
			date, producer, creator = extract_meta file, reader
			attrs[:d_filed] = date if date
			attrs[:bank] = find_bank producer, creator, reader
		end
		attrs[:d_filed] ||= File.mtime(file)
		return attrs
	end

	def self.read_field field_name, reader
		field = reader.info.inspect.match /(?<=:#{Regexp.quote field_name}=>)(#<[^>]+>|\"[^\"]+\")(?=,\s:|})/
		return nil unless field
		field = "#{field}"
		if(field_id = field.match /(?<=@id=)\d+(?=,)/)
			field_id = "#{field_id}".to_i
			field = reader.objects[field_id] if field_id > 0
		end
		return field
	end

	def self.clean_date str
		return nil if str.nil?
		case str
		when /\d{8}/
			date_s = "#{str.match /(?<=D:)\d{8}/}"
			date_s = date_s[6..7] << '-' << date_s[4..5] << '-' << date_s[0..3]
		when /\d{2}(\.\d{2}){2},/
			date_s = str.delete('"').split(',')[0].split('.').join('-')
		else
			return nil
		end
		date = Date.strptime(date_s, "%d-%m-%Y")
		return date
	end

	def self.find_bank producer, creator, reader
		meta_print = MetaPrint.find_by(producer: producer, creator: creator)
		if meta_print
			unless meta_print.bank.nil?
				return meta_print.bank
			else
				if meta_print.cover_prints
					#TODO CoverPrint search
				end
			end
		end
		return Bank.find_by(code_name: Bank::Format::BLANK)
	end

	def self.match collection, **params
		return false unless params and params.any?
		params[:producer] ||= ""
		params[:creator] ||= ""
		collection.each do |term|
			return term[0] if params[:producer].match term[1] and
				params[:creator].match term[2]
		end
		return false
	end

	def self.identify regex, reader
		receiver = PDF::Reader::PageTextReceiver.new
		reader.pages.first.walk(receiver)
		content = receiver.content
		return !!content.match(regex)
	end

	def self.extract_meta file, reader
		date = clean_date read_field("CreationDate", reader)
		producer = read_field "Producer", reader
		creator = read_field "Creator", reader
		return [date, producer, creator]
	end

	def self.correct_file file
		begin
			PDF::Reader.open(file) do |reader|
				yield reader
			end
			return true
		rescue StandardError => e
			if e.message == "PDF does not contain EOF marker"
				retry if trim_file file
			end
			puts "Unable to read #{File.basename(file,'.pdf')}"
			puts "ERROR: #{e.message}".red
			return false
		end
	end

	def self.trim_file file
		bytes = [37,37,69,79,70]
		j = 0
		end_pos = nil
		f = File.new(file)
		f.each_byte do |b|
			b == bytes[j] ? j += 1 : j = 0
			end_pos = f.pos if j == 5
		end
		if end_pos
			puts "DELETING FROM #{end_pos}"
			File.truncate(file, end_pos+5)
		end 
		return !!end_pos
	end

	def self.learn_from file, bank
		puts "#{File.basename file} ; #{bank}"
		learnt = nil
		if File.exist? file
			correct_file file do |reader|
				date, producer, creator = extract_meta file, reader
				puts "DATE #{date}, PROD #{producer}, CREAT #{creator}"
				registered = MetaPrint.find_by(producer: producer, creator: creator)
				if registered
					if registered.bank != bank
						raise #TODO: Check cover prints
					else
						learnt = registered
					end
				else
					learnt = MetaPrint.create(bank: bank, producer: producer, creator: creator)
				end
			end
		end
		learnt
	end
end