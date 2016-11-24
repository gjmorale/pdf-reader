class Table

	attr_reader :rows

	def initialize(headers, bottom = nil)
		@bottom = bottom
		@headers = headers
	end

	def set_headers_width
		size = 1
		size = @headers.map {|header| header.width}.max
		puts "SIZE:   #{size}"
		@headers.each {|header| header.width = size}
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

	def set_range (line_size, line_height)
		unless @range
			yi = (@offset ? @offset.bottom+1 : @headers_row.yf+1)
			if @bottom
				yf = @bottom.top - 1 
			else
				yf = line_height - 1
			end
			#puts "Y: #{y} = #{total}/#{n}"
			xi = @headers.first.left
			xf = @headers.last.right
			#puts "Searching between [#{xi},#{xf},#{y}]"
			table_offset = Setup::Table.offset
			xi = xi - table_offset >= 0 ? xi - table_offset : 0
			xf = xf + table_offset <= line_size ? xf + table_offset : line_size
			#puts "Searching between [#{xi},#{xf},#{y}]"
			@range = [xi,xf,yi,yf]
		end
	end

	def set_borders
		@headers.each.with_index do |header, i|
			header.border ||= TextNode.new(header.left, header.right, header.position.y)
			case i
			when 0
				header.outer_left = @range[0]
				header.outer_right = @headers[i+1].left-1
			when @headers.size - 1
				header.outer_left = @headers[i-1].right+1
				header.outer_right = @range[1]
			else
				header.outer_right = @headers[i+1].left-1
				header.outer_left = @headers[i-1].right+1
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
		if @headers_row.multiline?
			line = []
			@headers_row.width.times.map {|n| line[n] = (n == 0 ? "|" : "\n|")}
			line = Multiline.generate line
		else
			line = "\n|"
		end
		@headers.each do |header|
			str = fit_in_space(header.text, get_header_size(header))
			line << str
			line.fill if line.is_a? Multiline
			line << "|"

			#puts "OUTSIDE"
			#puts line.strings
			#puts line
			#puts "#{fit_in_space header.text}"
		end
		puts "_"*(line.length-1)
		puts line.to_s
		puts "-"*(line.length-1)

		@rows.each.with_index do |row, n|
			line = "|"
			if row.multiline?
				line = []
				row.width.times.map {|n| line[n] = (n == 0 ? "|" : "\n|")}
				line = Multiline.generate line
			end
			@headers.each do |header|
				str = fit_in_space(header.results[n].result, get_header_size(header))
				line << str
				line.fill if line.is_a? Multiline
				line << "|"
			end
			puts line.to_s
		end
		puts "-"*line.length
	end

	def fit_in_space(text, size)
		return text[0,size] if text.length > size
		text << " " while text.length < size
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
			header.set_results @rows.size
		end		
	end

	def get_guide
		guide = nil
		@headers.each do |header|
			guide = header if header.guide?
		end
		guide
	end

	def execute reader
		first_header = @headers.sort.first
		reader.move_to first_header
		set_headers_width
		@headers_row = reader.set_header_limits(@headers)
		reader.move_to @offset if @offset
		reader.read_next_field @bottom if @bottom
		set_range reader.line_size, reader.line_height
		puts @range
		set_borders
		@rows = reader.get_rows(@range, get_guide)
		puts @rows
		set_results
		@headers.reverse_each.with_index do |header, i|
			reader.get_column(header, @rows)
			if @headers.size-i >= 2
				next_header = @headers[@headers.size-i-2] 
				next_header.border.xf = header.position.xi-1
			end
=begin
=end
		end
		reader.correct_results(@headers, @rows)
=begin		
		set_borders
		print_borders
=end
	end

	def print_borders
		@headers.each do |header|
			header.print_borders
		end
	end

end