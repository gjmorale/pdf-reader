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

	private 

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
