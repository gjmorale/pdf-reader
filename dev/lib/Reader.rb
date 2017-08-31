require 'rubygems'

class Reader

	INPUT_PATH = 'in'

	attr_reader :page
	attr_reader :offset

	# file: File to be read by page
	# offset: y position of last read item
	def initialize(file)
		@stashed = 0
		@last_page = []
		@last_offset = []
		@file = file
		@page = 1
		@offset = 0
		file_name = "#{@file[@file.rindex('/')+1..-1]}"
		file_path = "#{@file}/#{file_name}_#{@page}.page"
		if File.exist? file_path
			first_page = File.new(file_path, 'r:UTF-8')
		end
		@page_content = PageContent.new(@page, first_page.read)
	end

	def stash
		@stashed += 1 
		@last_page << [@stashed, @page]
		@last_offset << [@stashed, @offset]
		return @stashed
	end

	def pop index, move = true
		i = nil
		while index != i
			last_page = @last_page.pop
			last_offset = @last_offset.pop
			i = last_offset[0]
		end
		if move
			@page = last_page[1]
			@offset = last_offset[1]
		end
	end

	def to_s
		"[Page: #{@page} , Offset: #{@offset}]"
	end

	# Allows banks execution to skip directly to a specific page
	def go_to page, offset = 0
		@page = page
		@offset = offset
	end

	def next_page
		go_to @page + 1
		
	end

	def slide_up value
		if @offset - value > 0
			@offset -= value
		else
			@offset = 0
		end	 
	end

	# Retrieves the number of columns from the actual page
	def line_size
		@page_content ? @page_content.line_size : 0
	end

	# Retrieves number of rows from the actual page
	def line_height
		@page_content ? @page_content.line_height : 0
	end

	# Moves the offset to the beggining of the specified field
	def move_to field, limit = 0, inverted = false
		original_pos = stash
		counter = limit != 0 ? 1 : 0
		while counter <= limit
			if match = read_next_field(field, nil, nil, Setup::Debug.overview, inverted)
				field = match
				break
			end
			counter += 1 if limit != 0
			@page += 1
			@offset = 0
		end
		if field.is_a? Field and field.position?
			@offset = field.position.y
			return field
		else
			pop original_pos
			return false
			#raise StopIteration, "Field #{field} is not present in the document"
		end
	end

	# Moves the offset past the bottom of the specified field
	def skip field
		@offset += field.width
	end

	# Looks for the first occurrence of the field past the offset
	def read_next_field(field, from = nil, to = nil, verbose = false, inverted = false)
		#puts "LOOP #{field}"
		if not @page_content or @page_content.number != @page
			file_name = "#{@file[@file.rindex('/')+1..-1]}"
			file_path = "#{@file}/#{file_name}_#{@page}.page"
			if File.exist? file_path
				page = File.new(file_path, 'r:UTF-8')
			else
				puts "EOF and #{field} not found" if verbose
				return Field.new("EOF")
			end
			@page_content = PageContent.new(@page, page.read)
		end
		return first_match(field, inverted) if field.is_a? Array
		return false if field.nil?
		if @page_content.search_next(field, @offset, from, to)
			#puts "Found #{field} in page #{field.position} at page #{@page}" if verbose
			return field
		else
			puts "Position for '#{field}' in page #{@page} from line #{@offset}: NOT FOUND" if verbose
			return false
		end
	end

	# Looks for results to right of the field
	# field: Position must be set first
	def find_results_for field
		@page_content.find_results_right(field)
	end

	# For testing with false content
	def mock_content content
		@page_content = PageContent.new(0,content)
	end

	# Sets the table headers borders to touch the neighbours positions
	def set_header_limits headers, bottom
		row = Row.new
		last = 0
		headers.each do |header|
			#puts "#{header.text}"
			#print 10, 10
			#print header.width, last, 100
			to = header.max_length
			found = read_next_field header, last, to, Setup::Debug.overview
			unless found and found.position
				#puts "NOT FOUND: #{header.text} #{last}-#{@offset} : #{@page}".red
				#print 7
				return nil
			end
			@offset = bottom.bottom if bottom and bottom.bottom < header.top
			#puts "#{header} #{header.top} #{header.bottom} #{@offset}"
			row.yi = row.yi ? [header.top, row.yi].min : header.top
			row.yf = row.yf ? [header.bottom, row.yf].max : header.bottom
			#@offset = row.yi-1
			last = header.right
		end
		@offset = row.yf+1
		row
	end

	# Get Columns
	# rows: the rows to be recognized
	# headers: The header of the columns to be recognized
	# Goes row by row for each header looking for results
	# for the header. The header results must exist
	# initialy and have the same dimensions as the header.
	# For each iteration the headers position and border 
	# is recalculated. This way the information of every
	# result makes the search for the others more accurate.
	def get_columns headers, rows
		range = []
		headers.reverse_each.with_index do |header, col|
			rows.each.with_index do |row, i|
				range = [header.outer_left,header.left,header.right,header.outer_right]
				while not @page_content.search_results_left(range, row, header.results[i])
					range[3] -= 1
				end
				unless header.results[i].result == Result::NOT_FOUND
					header.recalculate_position(false, false, true, true) 
				end
			end
		end
	end

	# Calls a vertical search for the guide column to determine rows
	def get_rows range, guide, skips
		rows = []
		row = Row.new
		prev_row = nil
		row.yf = range[3]
		if skips
			regex = RegexHelper.regexify_skips(skips) 
			@page_content.clean(range, regex)
		end
		while (row_y = @page_content.get_row(range, guide))
			row_y -= 1 if row_y
			row.yi = row_y 
			if prev_row
				prev_row.upper_text = @page_content.get_chunk(range[0],range[1],row.yi+1,row.yf) 
			else
				row.lower_text = @page_content.get_chunk(range[0],range[1],row.yi+1,row.yf)
			end
			prev_row = row
			rows << row
			row = Row.new
			row.yf = row_y - 1
			range[3] = row_y - 1
		end
		prev_row.upper_text = @page_content.get_chunk(range[0],range[1],range[2],prev_row.yi-1) if prev_row
		rows
	end

	# Verifies for each result that the Result::NOT_FOUND
	# wasn't due to next result overstep
	def correct_results(headers, rows)
		headers.reverse_each.with_index do |header, col|
			# first col has no right neighbour
			if col == 0
				header.recalculate_position
			else
				next_header = headers[-col]
				rows.each.with_index do |row, i|
					r = header.results[i]
					next_r = next_header.results[i]
					# check for over stepping
					if @page_content.check_result(row, r, next_r)
						# if results changed then recalculate header
						#header.recalculate_position 
						#next_header.recalculate_position
					end
				end
			end
		end
	end

	def first_match posibilities, inverted = false
		result = nil
		posibilities.flatten!
		posibilities.each do |p|
			if read_next_field(p) and p.position
				if inverted
					result = p if result.nil? or result.top < p.top
				else
					result = p if result.nil? or result.top > p.top
				end
			end
		end
		puts "FOUND #{result} first in #{posibilities}" if Setup::Debug.overview
		result
	end

	def print range = 3, start = 0, show = 200
		puts "LINES FOR: #{@page} - #{@offset}"
		@page_content.print range, @offset, start, show
	end

	def find_text text, limit = 0, with_offset = false
		original_pos = stash
		result = nil
		temp_offset = with_offset ? @offset : nil
		go_to 1
		file_name = "#{@file[@file.rindex('/')+1..-1]}"
		counter = limit != 0 ? 1 : 0
		while File.exist?(file_path = "#{@file}/#{file_name}_#{@page}.page") and counter <= limit
			first_page = File.new(file_path, 'r:UTF-8')
			@page_content = PageContent.new(@page, first_page.read)
			if result = @page_content.find_text(text, temp_offset)
				break
			else
				counter += 1 if limit != 0
				@page += 1
				temp_offset = nil
			end
		end
		pop original_pos
		return result
	end
end