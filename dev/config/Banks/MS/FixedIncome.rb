	MorganStanley.class_eval do

		def analyse_fixed_income
			unless @reader.move_to(Field.new("CORPORATE FIXED INCOME"), 2)
				puts "No fixed income for this account"
				return false
			else
				print "Proccesing fixed income ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, true)
			headers << HeaderField.new("Face Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Unit Cost","Adj Unit Cost"], headers.size, to_arr(Setup::Type::FLOAT, 2), false)
			headers << HeaderField.new("Unit Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Total Cost","Adj Total Cost"], headers.size, to_arr(Setup::Type::AMOUNT, 2), false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new(["Est Ann Income","Accrued Interest"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			face_value = price = value = ai = "0.0"
			unfinished_title = title = false
			total = false
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						face_value = results[2] 
						value = results[6]
						ai = accured_interest(results[8])
					end
					new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
					if new_title
						new_title = unfinished_title.append new_title if unfinished_title
						unfinished_title = new_title.match(/CUSIP/) ? false : new_title 
						if title 
							titles = parse_position(title)
							new_positions << Position.new(titles[0], 
								to_number(face_value), 
								to_number(price), 
								to_number(value) + to_number(ai),
								titles[1])
						end
						title = unfinished_title ? false : new_title
						price = results[4]
						face_value = results[2] 
						value = results[6]
						ai = accured_interest(results[8])
						total = false
					else
						unfinished_title = false
					end
				end
			end
			if title
				titles = parse_position(title)
							new_positions << Position.new(titles[0], 
								to_number(face_value), 
								to_number(price), 
								to_number(value) + to_number(ai),
								titles[1])
			end
			if present
				total = SingleField.new("CORPORATE FIXED INCOME",
					[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Custom::AMOUNT_W_TERM, 
					Setup::Type::AMOUNT], 
					6, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, (to_number(total.results[3].result) + to_number(accured_interest(total.results[5].result)))
				return new_positions
			else 
				puts "FIXED INCOME table is missing."
				return analyse_fixed_income_alternative
			end
		end

		def analyse_fixed_income_alternative
			unless @reader.move_to(Field.new("CORPORATE FIXED INCOME"), 2)
				puts "No fixed income alternative for this account"
				return false
			else
				print "Proccesing fixed income alternative ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Face Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Unit Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Total Cost","Adj Total Cost"], headers.size, to_arr(Setup::Type::FLOAT, 2), false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new(["Est Ann Income","Accrued Interest"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			face_value = price = value = ai = "0.0"
			unfinished_title = title = false
			total = false
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						face_value = results[1] 
						value = results[4]
						ai = accured_interest(results[6])
					end
					new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
					if new_title
						new_title = unfinished_title.append new_title if unfinished_title
						unfinished_title = new_title.match(/CUSIP/) ? false : new_title 
						if title 
							titles = parse_position(title)
							new_positions << Position.new(titles[0], 
								to_number(face_value), 
								to_number(price), 
								to_number(value) + to_number(ai),
								titles[1])
						end
						title = unfinished_title ? false : new_title
						price = results[2]
						face_value = results[1] 
						value = results[4]
						ai = accured_interest(results[6])
						total = false
					else
						unfinished_title = false
					end
				end
			end
			if title
				titles = parse_position(title)
							new_positions << Position.new(titles[0], 
								to_number(face_value), 
								to_number(price), 
								to_number(value) + to_number(ai),
								titles[1])
			end
			if present
				total = SingleField.new("CORPORATE FIXED INCOME",
					[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT,  
					Setup::Type::AMOUNT], 
					6, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, (to_number(total.results[3].result) + to_number(accured_interest(total.results[5].result)))
				return new_positions
			else 
				puts "FIXED INCOME ALTERNATIVE table is missing."
			end
		end

	end