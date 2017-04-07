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
		#positions = []
		#@accounts.map{|a| positions += a.positions}
		#positions.each do |p|
		#	file.write(p.print)
		#end
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

class AssetTable
	attr_reader :name
	attr_reader :title
	attr_reader :headers
	attr_reader :table_end
	attr_reader :skips
	attr_reader :total
	attr_reader :offset
	attr_reader :page_end
	attr_reader :price_index
	attr_reader :quantity_index
	attr_reader :value_index
	attr_reader :total_index
	attr_reader :total_column

	def initialize reader
		@reader = reader
	end

	def analyze 
		checkpoint = @reader.stash
		load
		if go_to_title 
			if(positions = self.get_results)
				check_results positions
				@reader.pop checkpoint, false
				return positions
			end
		end
		@reader.pop checkpoint
		return false
	end

	def go_to_title 
		unless (found = @reader.move_to(title, 2))
			puts "No #{name} for this account"
		else
			print "Proccesing #{name} ... "
		end
		return found
	end

	def get_results
		new_positions = []
		quantity = price = value = "0.0"
		label = nil
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if total_column and results[total_column] == "Total"
					quantity = results[quantity_index]
					value = results[value_index]
				end
				new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
				if new_title
					if label 
						new_positions << Position.new(label, 
							BankUtils.to_number(quantity), 
							BankUtils.to_number(price), 
							BankUtils.to_number(value))
					end
					label = new_title
					price = results[price_index]
					quantity = results[quantity_index]
					value = results[value_index]
				end
			end
		end
		if label
			new_positions << Position.new(label, 
				BankUtils.to_number(quantity), 
				BankUtils.to_number(price), 
				BankUtils.to_number(value))
		end
		if present
			return new_positions
		else
			puts "#{name} table missing"
			return nil
		end
	end

	def check_results new_positions
		total.execute @reader
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		BankUtils.check acumulated, BankUtils.to_number(total.results[total_index].result)
	end


	def get_table verbose = false, interative_title = false
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
			cloned_table_end = BankUtils.clone_it table_end
			cloned_headers = BankUtils.clone_it headers
			cloned_offset = BankUtils.clone_it offset
			table = Table.new(cloned_headers, cloned_table_end, cloned_offset, skips)
			pre_table_reader = @reader.stash
			if (present = table.execute(@reader)) and table.width > 1
				yield table
				table.print_results if verbose
			else
				break
			end 
			@reader.pop pre_table_reader, (not present)
			if table.compare_bottom(page_end)
				@reader.go_to(@reader.page + 1) 
			else
				break
			end
		end
		return present
	end
end