class AssetTable
	attr_reader :name
	attr_reader :title
	attr_reader :headers
	attr_reader :table_end
	attr_reader :skips
	attr_reader :total
	attr_reader :offset
	attr_reader :page_end
	attr_reader :label_index
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
	attr_reader :position_parser
	attr_reader :title_dump
	attr_reader :title_limit
	attr_reader :iterative_title
	attr_reader :spanish
	attr_accessor :verbose

	def initialize reader, v = false
		@reader = reader
		@verbose = v
	end

	def pre_load *args
		#Override for custom parameters
	end

	def post_load
		#Override for custom parameters 
		#that depend on the load process
	end

	def analyze *args
		checkpoint = @reader.stash
		pre_load args
		load
		post_load
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
				new_title = title_dump ? "#{results[label_index]}".gsub(title_dump, "") : results[label_index]
				new_title = (new_title.nil? or new_title.empty? or new_title == Result::NOT_FOUND) ? nil : new_title
				if new_title
					if unfinished_regex
						new_title = unfinished_label.append new_title if unfinished_label
						unfinished_label = (new_title.match(unfinished_regex)) ? nil : new_title 
					end
					if label 
						titles = parse_position(label, @position_parser)
						new_positions << new_position(titles, quantity, price, value, accured_interests)
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
			titles = parse_position(label, @position_parser)
			new_positions << new_position(titles, quantity, price, value, accured_interests)
		end
		if present
			return new_positions
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def new_position titles, quantity, price, value, ai
		Position.new(titles[0], 
			BankUtils.to_number(quantity, spanish), 
			BankUtils.to_number(price, spanish), 
			BankUtils.to_number(value, spanish) + BankUtils.to_number(ai, spanish),
			titles[1])
	end

	def check_results new_positions
		puts "Pre-Check  reader #{@reader}" if verbose
		Setup::Debug.overview = true if verbose
		table_total = (total and total.execute(@reader)) ? total.results[total_index].result : nil
		ai_total = (table_total and total_ai_index) ? BankUtils.to_ai(total.results[total_ai_index].result) : nil
		Setup::Debug.overview = false if verbose
		total.print_results if verbose and table_total
		puts "Post-Check reader #{@reader}" if verbose
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		BankUtils.check acumulated, BankUtils.to_number(table_total, spanish) + BankUtils.to_number(ai_total, spanish)
		return new_positions
	end


	def get_table
		present = exit = false
		while not exit
			if title and (not present or iterative_title)
				if @reader.move_to(title, title_limit)
					puts "Processing #{name}" unless present
					puts "Title in #{@reader}" if verbose
					@reader.skip(title)
				else
					puts "#{title} not found" if verbose
					present = false
					break
				end
			end
			cloned_table_end = BankUtils.clone_it(table_end)
			cloned_table_end = [cloned_table_end, BankUtils.clone_it(page_end)] if page_end
			cloned_headers = BankUtils.clone_it headers
			cloned_offset = BankUtils.clone_it offset
			table = Table.new(cloned_headers, cloned_table_end, cloned_offset, skips)
			pre_table_reader = @reader.stash
			puts "Processing #{name} in page #{@reader.page}" unless title or present
			if table.execute(@reader) and table.width > 1
				present = true
				yield table
				table.print_results if verbose
			else
				puts "NOT PRESENT".yellow unless present
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