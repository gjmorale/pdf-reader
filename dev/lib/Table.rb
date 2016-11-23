class Table

	attr_reader :page
	attr_reader :file
	attr_reader :rows

	def initialize(file, page, headers, fixed_count, bottom = nil)
		@file = file
		@page = page
		@fixed_count = fixed_count
		@bottom = bottom
		@headers = headers
	end

	def set_offset(offset_field)
		@offset = offset_field
	end

	def calculate_offset(page_content)
		if page_content.search(@offset)
			return @offset.position.coords[2]
		else
			raise StopIteration, "Offset #{@offset} is not present in the document page"
		end
	end

	def calculate_bottom(range, page_content)
		if page_content.search(@bottom)
			bottom_y = @bottom.position.coords[2]
			@fixed_count = page_content.count_to_bottom(range[0], range[1], range[2], bottom_y, @headers)
		else
			raise StopIteration, "Bottom #{@bottom} is not present in the document page"
		end
	end

	def set_range (line_size)
		unless @range
			if @offset
				y = @offset.position.y
			else
				y = @headers.first.position.y
				@headers.each do |header|
					y = header.position.y if header.position.y > y
				end
			end
			#puts "Y: #{y} = #{total}/#{n}"
			xi = @headers.first.position.xi
			xf = @headers.last.position.xf
			#puts "Searching between [#{xi},#{xf},#{y}]"
			table_offset = Setup::Table.offset
			xi = xi - table_offset >= 0 ? xi - table_offset : 0
			xf = xf + table_offset <= line_size ? xf + table_offset : line_size
			#puts "Searching between [#{xi},#{xf},#{y}]"
			@range = [xi,xf,y]
		end
	end

	def set_borders
		@headers.each.with_index do |header, i|
			header.border ||= TextNode.new(header.position.xi, header.position.xf, header.position.y)
			case i
			when 0
				header.border.xi = @range[0]
				header.border.xf = @headers[i+1].position.xi-1
			when @headers.size - 1
				header.border.xi = @headers[i-1].position.xf+1
				header.border.xf = @range[1]
			else
				header.border.xf = @headers[i+1].position.xi-1
				header.border.xi = @headers[i-1].position.xf+1
			end
			header.print_borders
		end
	end

	def populate page_content
		@headers.each do |header|
			if page_content.search(header)
				#puts "HEADER: #{header.text} [#{header.position.coords[0]},#{header.position.coords[1]},#{header.position.coords[2]}]"
			else
				raise StopIteration, "Table header #{header} is not present in the document"
			end
		end
		range = get_range page_content.line_size
		range[2] = calculate_offset(page_content) if @offset
		calculate_bottom(range, page_content) if @bottom
		@headers.each do |header|
			@fixed_count.times do |i|
				header.results << Result.new(header.type)
			end
		end
		page_content.vertical_search(range[0], range[1], range[2], @fixed_count, @headers)
		print_results
		true
	end

	def print_results
		line = "\n|"
		@headers.each do |header|
			line << "#{fit_in_space(header.text, get_header_size(header))}|"
			#puts "#{fit_in_space header.text}"
		end
		puts "_"*(line.length-1)
		puts line
		puts "-"*(line.length-1)

		@fixed_count.times do |n|
		line = "|"
			@headers.each do |header|
				line << "#{fit_in_space(header.results[n].result, get_header_size(header))}|"
			end
			puts line
		end
		puts "-"*line.length
	end

	def fit_in_space(text, size)
		return text[0,size] if text.length >= size
		text = "#{text} " while text.length < size
		return text
	end

	def get_header_size(header)
		max = header.text.length
		header.results.each do |r|
			l = r.result.length
			max = l if l > max
		end
		max
	end

	def set_results
		@headers.each do |header|
			header.set_results @fixed_count
		end		
	end

	def execute reader
		reader.move_to @headers.sort.first
		reader.set_header_limits(@headers)
		reader.move_to @offset if @offset
		set_range reader.line_size
		set_borders
		@fixed_count = reader.count_to(@bottom) if @bottom
		set_results
		@headers.reverse_each.with_index do |header, i|
			reader.get_column(header, @fixed_count)
			if @headers.size-i >= 2
				next_header = @headers[@headers.size-i-2] 
				next_header.border.xf = header.position.xi-1
			end
		end
		reader.correct_results(@headers, @fixed_count)
		set_borders
		print_borders
	end

	def print_borders
		@headers.each do |header|
			header.print_borders
		end
	end

end