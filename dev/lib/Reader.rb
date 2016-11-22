require 'rubygems'
require 'pdf/reader'

class Reader

	def initialize(file)
		@reader = PDF::Reader.new(file) if file
		@page = 0
		@offset = 0
	end

	def line_size
		@page_content ? @page_content.line_size : 0
	end

	def read_fields(fields)
		fields.each do |field|
			read_field(field, field.page)			
		end
	end

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

	def read_next_field(field)
		if not @page_content or @page_content.number != @page
			raise #debugg
			page = @reader.pages[@page]
			return "Wrong page for this document" if page.nil?
			receiver = PDF::Reader::PageTextReceiver.new
			page.walk(receiver)

			@page_content = PageContent.new(page.number, receiver.content)
		end
		if @page_content.search_next(field, @offset)
			return true
		else
			puts "Position in page #{@page}: NOT FOUND"
			return false
		end
	end

	def find_results_for field
		@page_content.find_results_right(field)
	end

	def read_continue(fields)
		@page = 0
		@offset = 0
		fields.each do |field|
			while not read_next_field(field)
				@page += 1
			end
			if field.position?
				@offset = field.position.y
				page_content.find_results_right(field)
				field.print_results
			else
				raise StopIteration, "Field #{field} is not present in the document"
			end
		end
	end

	def mock_content content
		@page_content = PageContent.new(0,content)
	end

	def read_field(field, page_number)
		page = @reader.pages[page_number-1]
		return "Wrong page for this document" if page.nil?
		receiver = PDF::Reader::PageTextReceiver.new
		page.walk(receiver)

		page_content = PageContent.new(page.number, receiver.content)
		if page_content.search(field)
			page_content.find_results_right(field)
			field.print_results
			return true
		else
			puts "Position in page #{page_content.number}: NOT FOUND"
			return false
		end
	end

	def set_header_limits headers
		headers.each do |header|
			read_next_field header
		end
	end

	# calls a vertical search for the specific column
	def get_column header, row_number
		@page_content.vertical_search(row_number, header)
	end

	# Verifies for each result that the Result::NOT_FOUND
	# wasn't due to right-next result overstep
	def correct_results(headers, rows)
		headers.reverse_each.with_index do |header, col|
			unless col == 0
				next_header = headers[-col]
				rows.times do |row|
					r = header.results[row]
					next_r = next_header.results[row]
					if @page_content.check_result(r, next_r)
						header.recalculate_position 
						next_header.recalculate_position
					end
				end
			end
		end
	end

	def read_tables(tables)
		tables.each do |table|
			reader = PDF::Reader.new(table.file)
			
			page = reader.pages[table.page-1]
			return "Wrong page for this document" if page.nil?
			receiver = PDF::Reader::PageTextReceiver.new
			page.walk(receiver)

			page_content = PageContent.new(page.number, receiver.content)
			if table.populate(page_content)
				#puts "Position in page #{page_content.number}: Table populated"
			else
				puts "Table in page #{page_content.number}: NOT FOUND"
			end
		end
	end

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