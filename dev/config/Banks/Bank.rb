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
	attr_reader :price_default
	attr_reader :quantity_index
	attr_reader :quantity_default
	attr_reader :value_index
	attr_reader :value_default
	attr_reader :ai_index
	attr_reader :ai_default
	attr_reader :total_index
	attr_reader :total_ai_index
	attr_reader :total_column
	attr_reader :unfinished_regex
	attr_reader :title_dump
	attr_accessor :verbose

	def initialize reader, v = false
		@reader = reader
		@verbose = v
	end

	def analyze 
		checkpoint = @reader.stash
		load
		puts "Pre-Run  reader #{@reader}" if verbose
		if(positions = self.get_results)
			positions = check_results positions
			@reader.pop checkpoint, false
			return positions
		end
		puts "Post-Run reader #{@reader}" if verbose
		@reader.pop checkpoint
		return false
	end

	def get_results
		new_positions = []
		accured_interests = quantity = price = value = "0.0"
		unfinished_label = label = nil
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if total_column and results[total_column] == "Total"
					quantity = (quantity_default || results[quantity_index])
					value = (value_default || results[value_index])
					accured_interests = (ai_index ? BankUtils.to_ai(results[ai_index]) : 0.0).to_s
				end
				new_title = title_dump ? "#{results[0]}".gsub(title_dump, "") : results[0]
				new_title = (new_title.nil? or new_title.empty? or new_title == Result::NOT_FOUND) ? nil : new_title
				if new_title
					if unfinished_regex
						new_title = unfinished_label.append new_title if unfinished_label
						unfinished_label = (new_title.match(unfinished_regex)) ? nil : new_title 
					end
					titles = BankUtils.parse_position(label)
					if label 
						new_positions << Position.new(titles[0], 
							BankUtils.to_number(quantity), 
							BankUtils.to_number(price), 
							BankUtils.to_number(value) + BankUtils.to_number(accured_interests),
							titles[1])
					end
					label = unfinished_label ? nil : new_title
					price = (price_default || results[price_index]).to_s
					quantity = (quantity_default || results[quantity_index]).to_s
					value = (value_default || results[value_index]).to_s
					accured_interests = (ai_index ? BankUtils.to_ai(results[ai_index]) : 0.0).to_s
				else
					unfinished_label = nil
				end
			end
		end
		if label
			titles = BankUtils.parse_position(label)
			new_positions << Position.new(titles[0], 
				BankUtils.to_number(quantity), 
				BankUtils.to_number(price), 
				BankUtils.to_number(value) + BankUtils.to_number(accured_interests),
				titles[1])
		end
		if present
			return new_positions
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def check_results new_positions
		puts "Pre-Check  reader #{@reader}" if verbose
		table_total = (total and total.execute(@reader)) ? total.results[total_index].result : nil
		ai_total = (table_total and total_ai_index) ? BankUtils.to_ai(total.results[total_ai_index].result) : nil
		total.print_results if verbose and table_total
		puts "Post-Check reader #{@reader}" if verbose
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		BankUtils.check acumulated, BankUtils.to_number(table_total) + BankUtils.to_number(ai_total)
		return new_positions
	end


	def get_table(iterative_title = false)
		present = exit = false
		while not exit
			if title and (not present or iterative_title)
				if @reader.move_to(title, 2)
					puts "Processing #{name} ..." unless present
					@reader.skip(title)
				else
					present = false
					break
				end
			end
			cloned_table_end = BankUtils.clone_it(table_end)
			cloned_headers = BankUtils.clone_it headers
			cloned_offset = BankUtils.clone_it offset
			table = Table.new(cloned_headers, cloned_table_end, cloned_offset, skips)
			pre_table_reader = @reader.stash
			if table.execute(@reader) and table.width > 1
				present = true
				yield table
				table.print_results if verbose
			else
				@reader.pop pre_table_reader
				break
			end 
			if table.compare_bottom(page_end)
				@reader.go_to(@reader.page + 1) 
			else
				@reader.pop pre_table_reader, false
				break
			end
		end
		return present
	end
end