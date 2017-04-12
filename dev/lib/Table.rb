class Table

	attr_reader :rows
	attr_reader :width
	attr_reader :headers
	attr_reader :range

	def initialize(headers, bottom = nil, offset = nil, skips = nil)
		@bottom = bottom
		@offset = offset
		@headers = headers
		@skips = skips
	end

	def set_headers_width
		size = 1
		size = @headers.map {|header| header.width}.max
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
			if yi < Setup::Table.global_offset[2]
				yi = Setup::Table.global_offset[2]
			end
			if @bottom
				yf = @bottom.top - 1 
			else
				yf = line_height - 1 - Setup::Table.global_offset[3]
			end
			xi = @headers.first.left
			xf = @headers.last.right
			table_offset = Setup::Table.offset
			xi = xi - table_offset >= Setup::Table.global_offset[0] ? xi - table_offset : Setup::Table.global_offset[0]
			xf = xf + table_offset <= line_size - Setup::Table.global_offset[1] ? xf + table_offset : line_size - Setup::Table.global_offset[1]
			@width = yf-yi+1
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
			#header.print_borders
		end
	end

	def print_results
		return if @headers_row.nil?
		if @headers_row.multiline?
			line = []
			@headers_row.width.times.map {|n| line[n] = "|"}
			line = Multiline.generate line
		else
			line = "|"
		end
		@headers.each do |header|
			str = fit_in_space(header.text, get_header_size(header))
			str = Multiline.generate([str], false) if not str.is_a? Multiline and line.is_a? Multiline
			line << str
			line.fill if line.is_a? Multiline
			line << "|"
		end
		puts ("+"<<"-"*(line.length-2)<<"+").light_blue
		puts line.to_s.light_blue
		puts ("+"<<"-"*(line.length-2)<<"+").light_blue

		@rows.reverse_each.with_index do |row, n|
			line = "|"
			if row.multiline?
				line = []
				row.width.times.map {|m| line[m] = "|"}
				line = Multiline.generate line, false
			end
			@headers.each do |header|
				rr = header.results[-n-1].result
				r = rr == Result::NOT_FOUND ? "*" : rr
				r = Multiline.generate ([" "]) if line.is_a? Multiline and r == " "
				str = fit_in_space(r, get_header_size(header))
				line << str
				line.fill if line.is_a? Multiline
				line << "|"
			end
			puts line.to_s.blue
		end
		puts ("+"<<"-"*(line.length-2)<<"+").blue
	end

	def fit_in_space(text, size)
		size = [size, 100].min
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
		set_headers_width
		first_header = @headers.sort.first
		@headers_row = reader.set_header_limits(@headers)
		return false unless @headers_row
		@offset = reader.move_to(@offset) if @offset
		reader.skip @offset if @offset
		@bottom = reader.read_next_field(@bottom) if @bottom
		set_range reader.line_size, reader.line_height
		set_borders
		@rows = reader.get_rows(@range, get_guide, @skips)
		set_results
		reader.get_columns(@headers, @rows)
		reader.correct_results(@headers, @rows)
		reader.skip self
		return true
	end

	def print_borders
		@headers.each do |header|
			header.print_borders
		end
	end

	def compare_bottom possible
		if not possible and not @bottom
			return true
		elsif not possible or not @bottom
			return false
		else
			return posible.text == @bottom.text
		end
	end

end