MorganStanley.class_eval do 


	def analyse_etfs
		unless @reader.move_to(Field.new('EXCHANGE-TRADED & CLOSED-END FUNDS'), 1)
			puts "No etfs for this account"
			return false
		else
			print "Proccesing etfs ... "
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
		title = total = false
		present = get_table(headers, nil, table_end, nil, skips) do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if results[1] == "Total"
					total = true
					quantity = results[2]
					value = results[6]
				end
				new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
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
			total = SingleField.new('EXCHANGE-TRADED & CLOSED-END FUNDS',
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
			puts "ETFS table is missing."
		end
	end

	#TODO: Alternative
end