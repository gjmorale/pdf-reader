require_relative 'BankUtils.rb'
# Abstract bank class never to be instantiated
class Bank < Institution

	# Accounts to store information
	attr_accessor :accounts
	attr_reader :date_out
	attr_accessor :total_out

MONTHS = [[1, /jan/i],
		[2, /feb/i],
		[3, /mar/i],
		[4, /apr/i],
		[5, /may/i],
		[6, /jun/i],
		[7, /jul/i],
		[8, /aug/i],
		[9, /sep/i],
		[10, /oct/i],
		[11, /nov/i],
		[12, /dec/i]]

	def page_end
		nil
	end

	def total_s
		@total_out.to_s.sub(".",",")
	end

	def print_results  file
		file.write("Id_sec1;Id_fi1;Fecha;Instrumento;Cantidad;Precio;Monto\n")
		accounts.reverse_each do |acc|
			file.write("#{acc.code};;;Total;;;;#{acc.value_s}\n")
			acc.positions.each do |pos|
				file.write("#{acc.code};#{legacy_code};#{date_out};#{pos.print}")
			end
		end
		file.write(";;;Total;;;;#{total_s}\n")
	end

	def get_table(name, title, headers, offset, table_end, skips = nil, reader = nil, iterative_title = false, verbose = false)
		puts "Searching for #{name}"
		original_reader = @reader.stash
		present = false
		exit = false
		while not exit
			if title and (not present or iterative_title)
				if @reader.move_to(title, 2)
					puts "processing #{name}" unless present
				else
					present = false
					puts "no #{name} for this account"
					break
				end
			end
			cloned_table_end = clone_it table_end
			cloned_headers = clone_it headers
			cloned_offset = clone_it offset
			table = Table.new(cloned_headers, cloned_table_end, cloned_offset, skips)
			pre_table_reader = @reader.stash
			if (present = table.execute(@reader)) and table.width > 1
				yield table
				puts "\n"  if verbose
				table.print_results if verbose
			else
				break
				#return present if bottom.nil?
			end 
			@reader.pop pre_table_reader, present
			if table.compare_bottom(page_end)
				@reader.go_to(@reader.page + 1) 
			else
				break
			end
		end
		if present
			@reader.pop original_reader, false
			return true
		else
			puts "Table for #{name} not found"
			@reader.pop original_reader
			return nil
		end
	end

end

