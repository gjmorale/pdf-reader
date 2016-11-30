require 'rubygems'
require 'pdf/reader'

class Reader

	# file: File to be read by page
	# offset: y position of last read item
	def initialize(file)
		@reader = PDF::Reader.new(file) if file
		@page = 1
		@offset = 0
	end

	# Allows banks execution to skip directly to a specific page
	def go_to page, offset = 0
		@page = page - 1
		@offset = offset
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
	def move_to field
		while not read_next_field(field)
			@page += 1
		end
		if field.position?
			@offset = field.position.y
		else
			raise StopIteration, "Field #{field} is not present in the document"
		end
	end

	# Moves the offset past the bottom of the specified field
	def skip field
		@offset += field.width
	end

	# Looks for the first occurrence of the field past the offset
	def read_next_field(field)
		if not @page_content or @page_content.number != @page + 1
			#raise #debugg
			page = @reader.pages[@page]
			return "Wrong page for this document" if page.nil?
			receiver = PDF::Reader::PageTextReceiver.new
			page.walk(receiver)

			@page_content = PageContent.new(page.number, receiver.content)
			@offset = 0
		end
		if @page_content.search_next(field, @offset)
			#puts "Found #{field} in page #{@page}"
			return true
		else
			#puts "Position for #{field} in page #{@page}: NOT FOUND"
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
	def set_header_limits headers
		row = Row.new
		headers.each do |header|
			read_next_field header
			row.yi = row.yi ? [header.top, row.yi].min : header.top
			row.yf = row.yf ? [header.bottom, row.yf].max : header.bottom
		end
		row
	end

	# Calls a vertical search for the specific column
	def get_column header, rows
		@page_content.vertical_search(rows, header)
	end

	# Calls a vertical search for the guide column to determine rows
	def get_rows range, guide
		rows = []
		row = Row.new
		row.yf = range[3]
		while (row_y = @page_content.get_row(range, guide))
			row.yi = row_y 
			rows << row
			row = Row.new
			row.yf = row_y - 1
			range[3] = row_y - 1
		end
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
						header.recalculate_position 
						next_header.recalculate_position
					end
				end
			end
		end
	end

	# For debugging purposes only
	def print_file file
		reader = PDF::Reader.new(file)
		f_raw = File.open("#{file[0, file.length-4]}_inspect.txt",'w')
		f_raw.write("File INSPECTION\n")
		
		#Printed file for checking
		reader.pages.each do |page|
			f_raw.write("\nPAGE #{page.number}\n")
			receiver = PDF::Reader::PageTextReceiver.new
			page.walk(receiver)

			f_raw.write("\n#{receiver.content}")
		end
	end
end