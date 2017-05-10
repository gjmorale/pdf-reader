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
	attr_reader :alt_currency
	attr_accessor :verbose

	def initialize reader, v = false
		@reader = reader
		@verbose = v
	end

	def self.set_currs *args
		@@alt_currs = args[0] if args.any?		
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
		Setup::Debug.overview = true if verbose
		puts "Pre-Run  reader #{@reader}" if verbose
		if(positions = self.get_results)
			positions = check_results positions
			@reader.pop checkpoint, false
			Setup::Debug.overview = false if verbose
			return positions
		end
		puts "Post-Run reader #{@reader}" if verbose
		@reader.pop checkpoint
		Setup::Debug.overview = false if verbose
		return false
	end

	def each_result_do results
	end

	def get_results
		new_positions = []
		accured_interests = quantity = price = value = "0.0"
		unfinished_label = label = nil
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				each_result_do results
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
		quantity = BankUtils.to_number(quantity, spanish)
		price = BankUtils.to_number(price, spanish)
		value = BankUtils.to_number(value, spanish)
		ai = BankUtils.to_number(ai, spanish)
		price *= @@alt_currs[@alt_currency.to_sym] if @alt_currency
		value *= @@alt_currs[@alt_currency.to_sym] if @alt_currency
		titles[1] ||= ""
		titles[1] << "[Obtenido con #{@alt_currency} a $#{@@alt_currs[@alt_currency.to_sym].round(3)}]" if @alt_currency
		Position.new(titles[0], 
			quantity, 
			price, 
			value + ai,
			titles[1])
	end

	def parse_position str, type
		[str, nil]
	end

	def pre_check_do
	end

	def check_results new_positions
		return [] if new_positions.empty?
		pre_check_do
		puts "Pre-Check  reader #{@reader}" if verbose
		table_total = (total and total.execute(@reader)) ? BankUtils.to_number(total.results[total_index].result, spanish) : nil
		table_total *= @@alt_currs[@alt_currency.to_sym] if table_total and @alt_currency
		ai_total = (table_total and total_ai_index) ? BankUtils.to_number(BankUtils.to_ai(total.results[total_ai_index].result), spanish) : nil
		ai_total *= @@alt_currs[@alt_currency.to_sym] if ai_total and @alt_currency
		table_total += ai_total if table_total and ai_total
		total.print_results if verbose and table_total
		puts "Post-Check reader #{@reader}" if verbose
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		BankUtils.check acumulated, table_total
		return new_positions
	end


	def get_table
		present = exit = false
		while not exit
			if title and (not present or iterative_title)
				if(found_title = @reader.move_to(title, title_limit))
					puts "Processing #{name}" unless present
					puts "Title in #{@reader}" if verbose
					@reader.skip(found_title)
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
			puts "Executing table at #{@reader}" if verbose
			if table.execute(@reader) and table.width > 1
				present = true
				yield table
				table.print_results if verbose
			else
				puts "NOT PRESENT".yellow unless present
				@reader.pop pre_table_reader
				break
			end 
			puts "Table read and ended at #{@reader}" if verbose
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