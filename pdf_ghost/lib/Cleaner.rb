class Cleaner

	attr_reader :files

	WILDCHAR = '¶'

	def execute
		print "Processing"
		total = files.size
		puts " #{total} files: "
		files.each.with_index do |file, i|
			
			print "[%02d/%02d]" % [i+1, total]
			name = File.basename(file[1], '.pdf')
			file_name = "#{@output_path}/" << file[0]::DIR
			unless File.exist? "#{file_name}"
				Dir.mkdir(file_name) 
			end
			sub_file_name = "#{@output_path}/" << file[0]::DIR << "/" << name
			unless File.exist? "#{sub_file_name}"
				Dir.mkdir(sub_file_name) 
				#Dir.mkdir("#{sub_file_name}/raw")
			end
			f_input = File.open(file[1], 'rb')
			@reader = PDF::Reader.new(f_input)
			n = @reader.pages.size
			step = 0
			@reader.pages.each.with_index do |page, j|
				#raw_output = File.open("#{sub_file_name}/raw/#{name}_#{page.number}.raw", "w:UTF-8")
				#write(page.raw_content, raw_output, 1)
				receiver = PDF::Reader::PageTextReceiver.new
				page.walk(receiver)
				content = receiver.content
				f_output = File.open("#{sub_file_name}/#{name}_#{page.number}.page", "w:UTF-8")
				write(content, f_output)
				if ( prog = ((j+1)*100)/(n)) >= step
					delta = ((prog-step)/4+1)
					step += 4*delta
					print "."*delta 
				end
			end
			puts "[100%] #{name}"
		end
	end

	def write content, file, raw = 0
		file.write(content.encode("UTF-8", invalid: :replace, undef: :replace))
	end


	def load (files, output)
		unless Dir.exist? "#{output}"
			puts "No se encontró la carpeta temporal"
			puts "#{output}"
			puts "¿Quiere crear la carpeta? (Y/N)"
			if (STDIN.gets.chomp) =~ /^(Y|y|yes|Yes|YES|s|S|si|sí|Si|Sí|SI|SÍ)$/
				Dir.mkdir("#{output}") 
			else
				return "Not a DIR #{output}"
			end
		end 
		print "Loading......"
		@output_path = output
		@files = files
		print ".."
		FileUtils.rm_rf(Dir["#{@output_path}/*"])
		puts "...[100%]"
		return nil
	end

end