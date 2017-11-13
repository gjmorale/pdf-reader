#!/usr/bin/env ruby
# coding: utf-8

module FileMeta

	require 'rubygems'
	require 'pdf/reader'

	module FileMeta::Map
		PRODUCERS = [
			[BC, /Acrobat PDFWriter 5\.0 para Windows NT/],
			[BC, /Apache FOP Version 1\.0/],
			[BC, /GPL Ghostscript 9\.\d{2}/],
			[HSBC, /Actuate XML to PDF Converter 1\.0/],
			[MON, /ComponentOne PDF Generator 8\.0/],
			[MS, /Aspose\.Pdf\.Kit for \.NET 5\.0\.0\.1/],
			[MS, /PDFlib 7\.0\.4p3 \(zSeries USS\)/],
			[PER, /303l Linux \(64bit\)/],
			[SEC, /Adobe LiveCycle Output 8\.2/]
		]
		CREATORS = [
			[BC, /PDFCreator Version 1\.5\.1/],
			[CrediCorp, /wkhtmltopdf 0\.12\.3\.1/],
			[MS, /Morgan Stanley/],
			[PER, /Ricoh Production Print Solutions Afp2Pdf Version: 303l/]
		]
		IGNORE = [
			["", /Papyrus Server/],
			["", /PDFium/],
			["", /iText 2\.1\.0 \(by lowagie\.com\)/],
			["", /iTextSharp/],
			["", /iText 2\.1\.7 by 1T3XT/],
			["", /Mac OS X 10\.10\.2 Quartz PDFContext/],
			["", /Toolkit http:\/\/www\.activepdf\.com/],
			["", /phpToPDF\.com/],
			["fidelity", /303m z\/OS USS \(64bit\)/],
			["fidelity", /Ricoh Production Print Solutions Afp2Pdf Version: 303m/],
			["LV", /Powered By Crystal/]
		]
		FULL = [
			[BC,/aspEasyPDF 3\.30 http:\/\/www\.mitdata\.com/, /^$/],
			[BC,/Acrobat PDFWriter 5\.0 para Windows NT/, /Aplicaci.+n Mantenedores ADC - \[Procesos de Cierre\]/],
			[BC,/Apache FOP Version 1\.0/, /Apache FOP Version 1\.0/],
			[BC,/Mac OS X 10\.10\.2 Quartz PDFContext/, /Apache FOP Version 1\.0/],
			[BC,/GPL Ghostscript 9\.05/, /PDFCreator Version 1\.5\.1/],
			[BC,/GPL Ghostscript 9\.10/, /PDFCreator Version 1\.7\.3/],
			[CrediCorp,/Mac OS X 10\.10\.2 Quartz PDFContext/, /wkhtmltopdf 0\.12\.3\.1/],
			[CrediCorp,/modified using iTextSharp/, /wkhtmltopdf 0\.12\.3\.1/],
			[CrediCorp,/Mac OS X 10\.10\.2 Quartz PDFContext/, /wkhtmltopdf 0\.12\.3\.1/],
			[CrediCorp,/Qt 4\.8\.7"/, /wkhtmltopdf 0\.12\.3\.1/],
			[HSBC,/Actuate XML to PDF Converter 1\.0/, /Actuate/],
			[MON, /ComponentOne PDF Generator 8.0/,/^$/],
			[MS,//, /Morgan Stanley/i],
			[PER,/303l Linux \(64bit\)/, /Ricoh Production Print Solutions Afp2Pdf Version: 303l/],
			[SEC,/Adobe LiveCycle Output 8\.2/, /Adobe LiveCycle Output 8\.2/],
			[SEC,/Mac OS X 10\.10\.2 Quartz PDFContext/, /Adobe LiveCycle Output 8\.2/]
		]
		FULL_IGNORE = [
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
			["BCI",/GPL Ghostscript 9\.04/, /PDFCreator Version 1\.2\.3/],
			[nil,/IMPOSSIBLE MATCH/,/IMPOSSIBLE MATCH/]

		]
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
		date_s = ""
		puts str
		case str
		when /\d{8}/
			date_s = "#{str.match /(?<=D:)\d{8}/}"
			date_s = date_s[6..7] << '-' << date_s[4..5] << '-' << date_s[0..3]
		when /\d{2}(\.\d{2}){2},/
			date_s = str.delete('"').split(',')[0].split('.').join('-')
		end
		date = Date.strptime(date_s, "%d-%m-%Y")
		return date
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

	def self.classify_files in_path, recursive = false, date_from = nil, date_to = nil
		raise IOError, "No se encontró la carpeta #{in_path}" unless Dir.exist? "#{in_path}"

		search = recursive ? "#{in_path}/**/*.pdf" : "#{in_path}/*.pdf"
		files = Dir[search].sort
		files_out = []

		files.each.with_index do |filename, i|
			name = File.basename(filename,'.pdf')
			puts "[#{i+1}/#{files.size}]#{filename}"
			producer = creator = date = ""
			begin
				PDF::Reader.open(filename) do |reader|
					#puts "\n===> #{filename[filename.rindex('/')..-5]}"
					puts reader.info.inspect
					date = read_field("CreationDate", reader)
					next unless date
					date = clean_date date
					producer = read_field "Producer", reader
					creator = read_field "Creator", reader
				end
			rescue StandardError => e
				puts "Unable to read #{File.basename(filename,'.pdf')}"
				puts "ERROR: #{e.message}".red
				if e.message == "PDF does not contain EOF marker"
					bytes = [37,37,69,79,70]
					j = 0
					end_pos = nil
					f = File.new(filename)
					f.each_byte do |b|
						if b == bytes[j]
							j += 1
						else 
							j = 0
						end
						if j == 5
							end_pos = f.pos
						end
					end
					if end_pos
						puts "DELETING FROM #{end_pos}"
						gets
						File.truncate(filename, end_pos+5)
					end 
				end
				next
			end
			bank = 
				FileMeta.match(FileMeta::Map::FULL, producer: producer, creator: creator) || 
				FileMeta.match(FileMeta::Map::FULL_IGNORE, producer: producer, creator: creator)
			if date
				puts "TOO OLD" unless date_from.nil? or date_from <= date
				puts "TOO NEW" unless date_to.nil? or date_to >= date
				next unless date_from.nil? or date_from <= date
				next unless date_to.nil? or date_to >= date
				if bank and not bank.is_a? String
					puts "BANK? #{bank::LEGACY}"
					#gets
					files_out << [bank, filename, date] 
				elsif not bank
					puts "BANK? P:#{producer} C:#{creator}"
					producer ||= "^$"
					creator ||= "^$"
					puts "[#{name},\/#{producer.gsub('.','\\.')}\/, \/#{creator.gsub('.','\\.')}\/],"
					gets
				end
			else
				puts "NO DATE".red
			end
		end
		files_out
	end
end