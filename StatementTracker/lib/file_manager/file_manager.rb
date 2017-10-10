require 'fileutils'

module FileManager

	module FileFormats
		PDF = ["pdf","PDF"]
		XLS = ["xlsx","XLSX"]
		IMAGE = ["jpg","jpeg","png"]
		ALL = [
			PDF,
			XLS,
			IMAGE
		].flatten
	end

	module FileDates
		NUMBER_DATE = /(?<=\/|^)(20\d\d|(?<= )[1-9]\d)(?=$|\/)/i
		ALT_YEAR_DATE = /20[1-9]\d/i
		module Months
			JAN = [/(\/|^)(20[1-2][0-9][0-1]?1|(ENE(RO)?|JAN(UARY)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(ENE(RO)?|JAN(UARY)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 1]
			FEB = [/(\/|^)(20[1-2][0-9][0-1]?2|(FEB(rero)?(bruary)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(FEB(rero)?(bruary)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 2]
			MAR = [/(\/|^)(20[1-2][0-9][0-1]?3|(MAR(ZO)?(CH)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(MAR(ZO)?(CH)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 3]
			APR = [/(\/|^)(20[1-2][0-9][0-1]?4|(ABR(IL)?|APR(IL)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(ABR(IL)?|APR(IL)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 4]
			MAY = [/(\/|^)(20[1-2][0-9][0-1]?5|(MAY(O)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(MAY(O)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 5]
			JUN = [/(\/|^)(20[1-2][0-9][0-1]?6|(JUN(IO)?(E)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(JUN(IO)?(E)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 6]
			JUL = [/(\/|^)(20[1-2][0-9][0-1]?7|(JUL(IO)?(Y)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(JUL(IO)?(Y)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 7]
			AUG = [/(\/|^)(20[1-2][0-9][0-1]?8|(AGO(STO)?|AUG(OST)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(AGO(STO)?|AUG(OST)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 8]
			SEP = [/(\/|^)(20[1-2][0-9][0-1]?9|(SEP(T(IEMBRE)?)?|SEP(T(EMBER)?)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(SEP(T(IEMBRE)?)?|SEP(T(EMBER)?)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 9]
			OCT = [/(\/|^)(20[1-2][0-9]10|(OCT(UBRE)?(OBER)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(OCT(UBRE)?(OBER)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 10]
			NOV = [/(\/|^)(20[1-2][0-9]11|(NOV(IEMBRE)?(EMBER)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(NOV(IEMBRE)?(EMBER)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 11]
			DEC = [/(\/|^)(20[1-2][0-9]12|(DIC(IEMBRE)?|DEC(EMBER)?)( [^\/]+)?(.[a-zA-Z]{3,4})|([0-9]{1,2} )?(DIC(IEMBRE)?|DEC(EMBER)?)( (20\d\d|[1-9]\d).*)?)($|\/)/i, 12]

			ALL = [JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC]
		end
	end

	def self.exist? path, base_path: Paths::DROPBOX
		File.exist? base_path + '/' + path
	end

	def self.digest_this file
		Digest::MD5.file(Paths::DROPBOX + '/' + file).hexdigest
	end

	def self.get_file path, hash
		return false unless path and hash
		name = File.basename path
		if File.exist?(file = Paths::DROPBOX + "/#{path}")
		#CASE: Path is right
			digest = digest_this path
			if hash.eql? digest
				#CASE: Hash matches
				return path
			else
				#CASE: File modified
				return nil
			end
		else
			puts Paths::DROPBOX + "/#{path} => " + File.exist?(file = Paths::DROPBOX + "/#{path}").to_s
		#CASE: Path is wrong
			original_dir = path[0..path.rindex('/')-1]
			Dir[Paths::DROPBOX + "/#{original_dir}/*.{#{FileFormats::ALL.join(',')}}"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File renamed but not moved
					return file.sub(Paths::DROPBOX+'/','')
				end
			end
			Dir[Paths::DROPBOX + "/**/#{name}"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File moved but not renamed
					return file.sub(Paths::DROPBOX+'/','')
				end
			end
			Dir[Paths::DROPBOX + "/**/*.{#{FileFormats::ALL.join(',')}}"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File was moved and renamed
					raise IOError, "Unhandled File Location for File: #{path}"
					return nil
				end
			end
		end
		#Catch other cases
		raise IOError, "#{path} : #{hash} NO MATCH"
		return false
	end

	def self.get_raw file, raw_path
		return false unless file and raw_path
		unless raw_file = FileManager.get_raw_dir(raw_path)
			FileManager.set_raw_dir
			#return FileGhost.execute file, FileManager.output(raw_path)
		end
		return raw_file
	end

	def self.rm_raw raw_path
		return true #Don't modify anything yet
		return false unless raw_path
		if raw_file = FileManager.get_raw_dir(raw_path)
			return FileGhost.delete raw_file
		end
		return true
	end

	def self.load_from path, date_from, date_to, key = nil
		dbox_path = Paths::DROPBOX + '/' + path
		return false unless Dir.exist? dbox_path
		files = Dir[dbox_path + "**/*.{#{FileFormats::ALL.join(',')}}"]
		files_with_dates = []
		files.each do |f|
			next if key and not f =~ /\/[^\/]*#{Regexp.escape(key)}[^\/]*$/
			year = get_year f
			month = get_month f
			if year and month
				date = Date.new(year, month, -1)
			else
				date = File.mtime(f)
			end
			if date >= date_from and date <= date_to
				files_with_dates << [f.sub(Paths::DROPBOX+'/',''),date] 
			end
		end
		files_with_dates
	end

	def self.load_societies
		dirs = Dir[Paths::DROPBOX + "/**/"].map{|f| f.gsub(Paths::DROPBOX,'')}
		dirs.each do |f|
			next unless path_contains_root? f
			date_found = bank_found = false
			society_found = true
			root_found = false
			last_node = nil
			bank = year = month = nil
			societies = []
			path = ""
			full_path = ""
			f.split('/').each do |folder|
				next if folder == ""
				path << "#{folder}/" unless bank_found
				full_path << "#{folder}/"
				next if folder =~ /cartolas/i
				if root_found ||= path_contains_root?(folder)
					if is_date folder
						date_found = true
						year = get_year folder
					elsif is_month folder
						date_found = true
						month = get_month folder
						year ||= get_year folder
					elsif is_bank folder
						bank_found = true
						bank = Bank.find_bank folder
					elsif not date_found and not bank_found and root_found
						last_node = Society.new_from_folder folder, last_node
						unless last_node
							society_found = false
							break
						else
							societies << last_node
						end
					end
					break if month and bank_found
				end
			end
			#TODO: Refactor dividing this two sections
			if bank and society_found
				tax = nil
				parent = nil
				quantity = month ? get_quantities(full_path) : 1
				optional = 0
				societies.each do |soc|
					if parent and not soc.persisted?
						soc.parent = parent
						if soc.save
							soc.build_source_path(path: path[/#{Regexp.escape(parent.path)}.*#{Regexp.escape(soc.name)}/])
							soc.save!
						end
					end
					parent = soc
				end
				if bank and date_found and societies.last.leaf?
					if tax = societies.last.taxes.find_by(bank: bank)
						tax.source_paths.where(path: path).first_or_create
					else
						tax = societies.last.taxes.build(
							bank: bank,
							quantity: quantity, 
							optional: optional, 
							periodicity: Tax::Periodicity::MONTHLY)
						tax.source_paths.build(path: path)
						tax.save
					end
					if tax and month and year
						tax.quantity = [tax.quantity,quantity].max
						seq = tax.sequences.build(
							date: Date.new(year,month,-1),
							quantity: quantity,
							optional: [0,quantity-tax.quantity].max
						)
						tax.save
					end
				end
			end
		end
	end

	private 

		def self.path_contains_root? path
			Society.roots.any?{|root| path[Regexp.new(Regexp.escape(root.name))]}
		end

		def self.is_date str
			return !!(str =~ FileDates::NUMBER_DATE)
		end

		def self.get_year str
			year = str[FileDates::NUMBER_DATE]
			year ||= str[FileDates::ALT_YEAR_DATE]
			if year
				year = year.to_i if year
				year += 2000 if year < 1999
			end
			year
		end

		def self.is_month str
			FileDates::Months::ALL.each do |month|
				return true if str =~ month[0]
			end
			return nil
		end

		def self.get_month str
			FileDates::Months::ALL.each do |month|
				return month[1] if str =~ month[0]
			end
			return nil
		end

		def self.get_quantities path
			Dir[Paths::DROPBOX + "/" + path + "**/*.{#{FileFormats::ALL.join(',')}}"].size
		end

		def self.is_bank str
			Bank.dictionary str
		end

		def self.set_raw_dir original_file, raw_path
			return true #Dont modify anything yet
			raw_dir = FileManager.output(raw_path)
			unless Dir.exist? raw_dir
				Dir.mkdir(raw_dir)
			end 
			raw_file = raw_dir + "/" + File.basename(original_file)
			unless File.exist? raw_file
				FileUtils.copy_file original_file, "#{raw_dir}/temp", preserve = true
			end
		end

		def self.get_raw_dir raw_path
			file = FileManager.output(raw_path)
			return file if Dir.exist? file
			return nil
		end

		def self.output raw_path
			Paths::RAW + "/#{raw_path}"
		end

end
=begin
OBSOLETE, might be useful later for true tree archiving

	def self.reset_societies
		seed_socs Society.roots, Paths::SEED, nil
	end

	def self.seed_socs societies, path, parent
		info_file = "#{path}/.info"
		if societies and parent and not File.exist? info_file
			puts "INFO MISSING #{info_file} #{parent}"
		elsif parent and File.exist? info_file
			update_parents info_file, parent
		end
		existing_nodes = []
		original_nodes = Hash.new
		societies.each do |node|
			file = "#{path}/#{node.name}"
			existing_nodes << file
			original_nodes[file] = node
			unless File.exist? file
				FileUtils.mkdir file 
				register_info node, "#{file}/.info"
			end
		end
		nodes = Dir[path+"/*/"].map{|p| p[0..-2]}
		diff = nodes - existing_nodes
		diff.each do |new_node|
			next unless File.exist? "#{new_node}/.info"
			name = File.basename new_node
			node = Society.create(name: name, parent: parent)
			original_nodes[new_node] = node
		end
		has_samples = false
		nodes.each do |node|
			puts "#{File.basename node} IS A NODE? #{File.exist? "#{node}/.info"}"
			if File.exist? "#{node}/.info"
				parent = original_nodes[node]
				children = parent.children
				seed_socs children, node, parent
			else
				has_samples = true
			end
		end
		learn_from path if has_samples
	end

	def self.update_parents info_file, parent
		info = YAML.load_file(info_file)
		puts "READING #{parent}"
		if not info
			info = {updated_at: DateTime.now - 4.hours}
		elsif info[:updated_at].nil? or info[:updated_at] < File.mtime(info_file) - 4.hours
			info[:updated_at] = DateTime.now - 4.hours
			if info[:taxes]
				info[:taxes].each do |tax|
					bank = match_bank tax[:bank]
					new_tax = Tax.where(bank: bank, society: parent).first_or_create
					new_tax.update_attributes(tax[:attributes])
				end
			end
			if info[:attributes]
				parent.update_attributes(info[:attributes])
			end
		end
		puts "READ #{parent} with #{parent.taxes.size}"
		register_info parent, info_file
	end

	def self.register_info node, path
		if node.valid?
			info = {updated_at: DateTime.now - 4.hours}
			info[:attributes] = Hash.new
			info[:attributes][:name] = node.name if node.name?
			info[:attributes][:rut] = node.rut if node.rut?
			if node.taxes.any?
				info[:taxes] = []
				node.taxes.each do |tax|
					tax_hash = Hash.new
					tax_hash[:bank] = tax.bank.code_name
					tax_hash[:attributes] = Hash.new
					tax_hash[:attributes][:quantity] = tax.quantity
					tax_hash[:attributes][:periodicity] = tax.periodicity
					info[:taxes] << tax_hash
				end
			end
			puts "WRITTING #{node}"
			puts info
			File.open(path, 'w') { |fo| fo.puts info.to_yaml }
		end
	end
=end
