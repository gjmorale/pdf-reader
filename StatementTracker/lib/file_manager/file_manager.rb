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
		NUMBER_DATE = /^(( +|-)+[0-9]+)*20[0-9]{2}(( +|-)+[0-9]+)*$/i
		module Months
			JAN = [/^[0-9]*\s*(ENE(RO)?|JAN(UARY)?)\s*[0-9]*$/i, 1]
			FEB = [/^[0-9]*\s*(FEB(rero)?(bruary)?)\s*[0-9]*$/i, 2]
			MAR = [/^[0-9]*\s*(MAR(ZO)?(CH)?)\s*[0-9]*$/i, 3]
			APR = [/^[0-9]*\s*(ABR(IL)?|APR(IL)?)\s*[0-9]*$/i, 4]
			MAY = [/^[0-9]*\s*(MAY(O)?)\s*[0-9]*$/i, 5]
			JUN = [/^[0-9]*\s*(JUN(IO)?(E)?)\s*[0-9]*$/i, 6]
			JUL = [/^[0-9]*\s*(JUL(IO)?(Y)?)\s*[0-9]*$/i, 7]
			AUG = [/^[0-9]*\s*(AGO(STO)?|AUG(OST)?)\s*[0-9]*$/i, 8]
			SEP = [/^[0-9]*\s*(SEP(T(IEMBRE)?)?|SEP(T(EMBER)?)?)\s*[0-9]*$/i, 9]
			OCT = [/^[0-9]*\s*(OCT(UBRE)?(OBER)?)\s*[0-9]*$/i, 10]
			NOV = [/^[0-9]*\s*(NOV(IEMBRE)?(EMBER)?)\s*[0-9]*$/i, 11]
			DEC = [/^[0-9]*\s*(DIC(IEMBRE)?|DEC(EMBER)?)\s*[0-9]*$/i, 12]
			ALL = [JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC]
		end
	end

	def self.digest_this file
		Digest::MD5.file(Paths::DROPBOX + file).hexdigest
	end

	def self.get_file path, hash
		return false unless path and hash
		name = File.basename path
		if File.exist?(file = Paths::DROPBOX + "#{path}")
		#CASE: Path is right
			digest = digest_this path
			if hash.eql? digest
				#CASE: Hash matches
				return file
			else
				#CASE: File modified
				return nil
			end
		else
		#CASE: Path is wrong
			original_dir = File.dirname path
			Dir[Paths::DROPBOX + "#{original_dir}/*.pdf"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File renamed but not moved
					return file
				end
			end
			Dir[Paths::DROPBOX + "/**/#{name}"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File moved but not renamed
					raise IOError, "Unhandled File Location for File: #{path}"
					return file
				end
			end
			Dir[Paths::DROPBOX + "/**/*.pdf"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File was moved and renamed
					raise IOError, "Unhandled File Location for File: #{path}"
					return file
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
		return false unless raw_path
		if raw_file = FileManager.get_raw_dir(raw_path)
			return FileGhost.delete raw_file
		end
		return true
	end

	def self.load_from path, date_from, date_to
		dbox_path = Paths::DROPBOX + '/' + path
		return false unless Dir.exist? dbox_path
		files = Dir[dbox_path + "/**/*.{#{FileFormats::ALL.join(',')}}"]
		files.select{|f| File.mtime(f) >= date_from and File.mtime(f) <= date_to }
	end

	def self.load_societies
		dirs = Dir[Paths::DROPBOX + "/**/"].map{|f| f.gsub(Paths::DROPBOX,'')}
		known_paths = []
		dirs.each do |f|
			date_found = bank_found = false
			society_found = true
			last_node = nil
			bank = quantity = optional = nil
			societies = []
			path = full_path = ""
			f.split('/').each do |folder|
				next if folder == ""
				path << "#{folder}/" unless bank_found
				full_path << "#{folder}/"
				if is_date folder
					date_found = true
				elsif is_bank folder
					bank_found = true
					bank = Bank.find_bank folder
				elsif not date_found and not bank_found
					last_node = Society.new_from_folder folder, last_node
					unless last_node
						society_found = false
						break
					else
						societies << last_node
					end
				end
				if bank_found and date_found and society_found
					min, max = get_quantities(full_path)
					quantity = min
					optional = max - min
					break
				end
			end
			if bank_found and date_found and society_found
				unless known_paths.include? path
					known_paths << path
					parent = nil
					societies.each do |soc|
						if parent and not soc.persisted?
							soc.parent = parent
							soc.save
						end
						parent = soc
					end
					if bank 
						tax = societies.last.taxes.build(
							bank: bank, 
							source_path: path[0..-2], 
							quantity: quantity, 
							optional: optional, 
							periodicity: Tax::Periodicity::MONTHLY)
						tax.save
					end
				end
			end
		end
		#puts known_paths
	end

	private 

		def self.is_date str
			return !!(str =~ FileDates::NUMBER_DATE)
		end

		def self.get_quantities path
			files = Dir[Paths::DROPBOX + "/" + path + "**/*.{#{FileFormats::ALL.join(',')}}"]
			min_q = max_q = nil
			FileDates::Months::ALL.each do |month|
				q = files.select{|f| f =~ month[0]}.size
				min_q ||= q
				max_q ||= q
				min_q = [min_q, q].min
				max_q = [max_q, q].max
			end
			[min_q, max_q]
		end

		def self.is_bank str
			Bank.dictionary str
		end

		def self.set_raw_dir original_file, raw_path
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
