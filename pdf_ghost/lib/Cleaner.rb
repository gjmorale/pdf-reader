class Cleaner
	require 'shellwords'

	WILDCHAR = '¶'

	@forbiddens = []
	@forbiddens_raw = []
	@matches = 0
	@last_count = 0

	def execute
		print "Processing"
		files = Dir["#{@input_path}/#{@format}/*.{pdf,PDF}"]
		total = files.size
		puts " #{total} files: "
		files.each.with_index do |file, i|
			
			print "[%02d/%02d]" % [i+1, total]
			name = File.basename(file, '.pdf')
			dir_name = File.dirname(file)
			dir_name = dir_name[dir_name.rindex('/')+1..-1]
			file_name = "#{@output_path}/" << dir_name
			unless File.exist? "#{file_name}"
				Dir.mkdir(file_name) 
			end
			sub_file_name = "#{@output_path}/" << dir_name << "/" << name
			unless File.exist? "#{sub_file_name}"
				Dir.mkdir(sub_file_name) 
				#Dir.mkdir("#{sub_file_name}/raw")
			end
			f_input = File.open(file, 'rb')
			@reader = PDF::Reader.new(f_input)
			correct_format file
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
			puts "[100%] #{name} (#{@matches - @last_count})"
			@last_count = @matches
		end
		puts "#{@matches} elements detected and replaced"
	end

	def write content, file, raw = 0
		new_content = ""
		content.each_line do |line|
			new_content << clean(line, raw)
		end
		file.write(new_content.encode("UTF-8", invalid: :replace, undef: :replace))
	end


	def load (input, output, format = "*", source = nil )
		return "No se encontró la carpeta #{input}" unless Dir.exist? "#{input}"
		Dir.mkdir("#{input}/#{format}") unless Dir.exist? "#{input}/#{format}"
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
		@input_path = input
		@format = format
		@source_path = source
		if @source_path
			File.open(@source_path,'r') do |file|
				@forbiddens = []
				@forbiddens_raw = []
				file.each_line do |line|
					regex = regexify(line.strip!)
					@forbiddens << regex if regex
					regex = regexify(line, true)
					@forbiddens_raw << regex if regex
				end
			end
		end
		print ".."
		@last_count = @matches = 0
		FileUtils.rm_rf(Dir["#{@output_path}/#{@format}/*"])
		puts "...[100%]"
		return nil
	end

	def regexify term, raw = false
		return nil if term.nil? or term.empty?
		term = Regexp.escape term
		regex = ""
		if raw
			regex << '(' << term << ')' << '(?:.+Tj)'
		else
			skip = true
			term.each_char do |char|
				unless char == WILDCHAR
					regex << "#{WILDCHAR}*" unless skip
					skip = (char == "\\")
					regex << char
				end
			end
		end
		Regexp.new(regex, true)
	end

	def clean line, capture_group = 0
		return line unless @source
		new_line = line
		forbiddens = capture_group == 1 ? @forbiddens_raw : @forbiddens
		forbiddens.each do |forbidden|
			line.match(forbidden){|m|
				@matches += 1
				xi = m.offset(capture_group)[0]
				xf = m.offset(capture_group)[1]
				start = middle = final = ""
				if xi > 0
					start = new_line[0..xi-1]
				end
				if xi < xf
					middle = '?'*(xf-xi)
				end
				if xf < line.length-1
					final = new_line[xf..-1]
				end
				new_line = start << middle << final
			}
		end
		new_line
	end

	def correct_format file
		#page = @reader.pages.first
		blanks = false
		if @reader.pages.any? do |page|
				receiver = PDF::Reader::PageTextReceiver.new
				page.walk(receiver)
				receiver.content.lines.size == 0
			end
			puts "#{file}"
			temp = "#{File.dirname file}/#{File.basename file, '.pdf'}.ps"
			_file = Shellwords.shellescape file
			_temp = Shellwords.shellescape temp
			system "pdftops #{_file} #{_temp}"
			system "ps2pdf13 #{_temp} #{_file}"
			system "rm #{_temp}"
			f_input = File.open(file, 'rb')
			@reader = PDF::Reader.new(f_input)
		end
	end

end