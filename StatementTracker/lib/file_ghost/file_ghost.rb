#FileUtils.rm_rf(Dir["#{@output_path}/*"])
require_relative 'pdf_reader_override.rb'
module FileGhost

	WILDCHAR = '¶'

	def self.execute file, output
		return false unless output.include? Paths::RAW
		begin
			f_input = File.open(file, 'rb')
			@reader = PDF::Reader.new(f_input)
			n = @reader.pages.size
			step = 0
			@reader.pages.each.with_index do |page, j|
				receiver = PDF::Reader::PageTextReceiver.new
				page.walk(receiver)
				content = receiver.content
				f_output = File.open("#{output}/#{name}_#{page.number}.page", "w:UTF-8")
				write(content, f_output)
				if ( prog = ((j+1)*100)/(n)) >= step
					delta = ((prog-step)/4+1)
					step += 4*delta
					print "."*delta 
				end
			end
			puts "[100%] #{name}"
			return output
		rescue StandardError => e
			puts e.inspect
			FileUtils.rm_rf(output)
			return nil
		end
	end

	def self.delete output
		return false unless output.include? Paths::RAW
		FileUtils.rm_rf(output)
	end

	def self.write content, file
		file.write(content.encode("UTF-8", invalid: :replace, undef: :replace))
	end

end