MorganStanley.class_eval do



	def analyse_mutual_funds
		unless @reader.move_to(Field.new("MUTUAL FUNDS"), 2)
			puts "No mutual funds for this account"
			return false
		else
			print "Proccesing mutual funds ... "
		end

		table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		headers = []
		headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
		headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, true)
		headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
		headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		skips = ['.*(?:Asset Class:).*']
		new_positions = []
		quantity = price = value = "0.0"
		title = false
		total = false
		title_dump = /(Long Term Reinvestments|Short Term Reinvestments|Cumulative\ *Cash\ *Distributions|Total Purchases vs Market Value|Net Value Increase\/\(Decrease\))/
		present = get_table("mutual funds", nil, headers, nil, table_end, skips) do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if results[1] == "Total"
					total = true
					price = results[4]
					quantity = results[2] 
					value = results[6]
				end
				new_title = "#{results[0]}".gsub(title_dump, "")
				new_title = (new_title.nil? or new_title.empty? or new_title == Result::NOT_FOUND) ? false : new_title
				if new_title
					if title 
						new_positions << Position.new(title, 
							to_number(quantity), 
							to_number(price), 
							to_number(value))
					end
					title = new_title
					price = results[4]
					quantity = results[2] 
					value = results[6]
					total = false
				end
			end
		end
		if title
			new_positions << Position.new(title, 
				to_number(quantity), 
				to_number(price), 
				to_number(value))
		end
		if present
			total = SingleField.new("MUTUAL FUNDS",
				[Setup::Type::PERCENTAGE, 
				Setup::Type::AMOUNT, 
				Setup::Type::AMOUNT, 
				Custom::AMOUNT_W_TERM, 
				Setup::Type::AMOUNT, 
				Setup::Type::FLOAT], 
				4, Setup::Align::LEFT)
			total.execute @reader
			acumulated = 0
			new_positions.map{|p| acumulated += p.value}
			check acumulated, to_number(total.results[2].result)
			return new_positions
		else 
			puts "MUTUAL FUNDS table is missing."
			return analyse_mutual_funds_alternative
		end
	end

	def analyse_mutual_funds_alternative
		unless @reader.move_to(Field.new("MUTUAL FUNDS"), 2)
			puts "No mutual funds alternative for this account"
			return false
		else
			print "Proccesing mutual funds alternative ... "
		end

		table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		headers = []
		headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
		headers << HeaderField.new("Quantity", headers.size, Custom::TOTAL_AMOUNT, true)
		headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
		headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		skips = ['.*(?:Asset Class:).*']
		new_positions = []
		quantity = price = value = "0.0"
		title = share_price = false
		title_dump = /(Purchases|Reinvestments|Total .* vs Market Value|Cumulative\ *Cash\ *Distributions|Net Value Increase\/\(Decrease\))+/i
		present = get_table(headers, nil, table_end, nil, skips) do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if results[2] != Result::NOT_FOUND
					title = results[0].inspect.gsub(title_dump, '')
					share_price = to_number(results[2])
				end
				if results[7] != Result::NOT_FOUND
					new_positions << Position.new(title, 
							to_number(results[1]), 
							share_price, 
							to_number(results[4]))
				end
			end
		end
		if title
			new_positions << Position.new(title, 
				to_number(quantity), 
				to_number(price), 
				to_number(value))
		end
		if present
			total = SingleField.new("MUTUAL FUNDS",
				[Setup::Type::PERCENTAGE, 
				Setup::Type::AMOUNT, 
				Setup::Type::AMOUNT, 
				Custom::AMOUNT_W_TERM, 
				Setup::Type::AMOUNT, 
				Setup::Type::FLOAT], 
				4, Setup::Align::LEFT)
			total.execute @reader
			acumulated = 0
			new_positions.map{|p| acumulated += p.value}
			check acumulated, to_number(total.results[2].result)
			return new_positions
		else 
			puts "MUTUAL FUNDS alternative table is missing."
			return nil
		end
	end

end