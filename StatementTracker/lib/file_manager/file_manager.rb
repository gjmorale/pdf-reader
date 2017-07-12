module FileManager

	def self.get_file path, hash
		return false unless path and hash
		name = File.basename path, '.pdf'
		if File.exist?(file = Paths::DROPBOX + "#{path}")
		#CASE: Path is right
			digest = Digest::MD5.file(file).hexdigest
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
			Dir[Paths::DROPBOX + "/**/#{name}.pdf"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File moved but not renamed
					return file
				end
			end
			Dir[Paths::DROPBOX + "/**/*.pdf"].each do |file|
				digest = Digest::MD5.file(file).hexdigest
				if hash.eql? digest
				#CASE: File was moved and renamed
					return file
				end
			end
		end
		#Catch other cases
		raise IOError, "#{path} : #{hash} NO MATCH"
		return false
	end

	def self.get_raw_dir raw_path
		file = FileManager.output(raw_path)
		return file if Dir.exist? file
		return nil
	end

	def self.output raw_path
		Paths::RAW + "/#{raw_path}"
	end

	def self.get_raw file, raw_path
		return false unless file and raw_path
		unless raw_file = FileManager.get_raw_dir(raw_path)
			return FileGhost.execute file, FileManager.output(raw_path)
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

	def self.read_new client = nil
		sub = "**"
		if client
			if client.is_a? Integer
				client = Client.find(client)
			elsif client.is_a? Client
				client = client
			elsif client.is_a? String
				client = Client.find_by(name: client)
			end
		end
		sub = client.name if client
		return FileMeta.classify_files Dir[Paths::INPUT + "/#{sub}/*.pdf"]
	end

end