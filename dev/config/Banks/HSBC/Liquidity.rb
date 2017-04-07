HSBC.class_eval do

	def liquidity_for account
		new_positions = []
		search = Field.new("Liquidity and Money Market#{account.title}")
		puts "Liquidity and Money Market#{account.title}"
		if search.execute @reader
			pos = nil
			new_positions += pos if(pos = get_current_account)
			new_positions += pos if(pos = get_fx)
			return new_positions
		else 
			puts " - No Liquidity for this account"
			return false
		end
	end

	def get_current_account
		offset = Field.new("Current Accounts")
		page_end = Field.new(" Account: ")
		bottom = Field.new("Total")
		headers = []
		headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
		headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
		headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
		headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
		headers << HeaderField.new(["% Acc.","% Liq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		#table = Table.new(headers, bottom, offset)
		new_positions = []
		present = get_table(headers, offset, bottom, page_end, nil, nil) do |table|
			table.rows.each.with_index do |r,i|
				results = table.headers.map{|h| h.results[i].result}
				titles = parse_position results[2], 'ACCOUNT'

				new_positions << Position.new(titles[0], 
					to_number(results[1]), 
					1.0,
					to_number(results[4]), 
					titles[1])
			end
		end
		if present
			total = SingleField.new("Total",[Setup::Type::AMOUNT])
			total.execute @reader
			acumulated = 0
			new_positions.map{|p| acumulated += p.value}
			check acumulated, to_number(total.results[0].result)
			return new_positions
		else
			puts " - No Current Account Liquidity for this account"
			return false
		end
	end

	def get_fx
		if Field.new("Foreign Exchange").execute @reader
			@reader.slide_up 10
			offset = Field.new("Foreign Exchange")
			page_end = Field.new(" Account: ")
			bottom = Field.new("Total")
			headers = []
			# TODO: Headers skkiped due t repeated text Nominal amount
			#headers << HeaderField.new(["Buy","Cur."], headers.size, Setup::Type::CURRENCY, true, 4, Setup::Align::LEFT)
			#headers << HeaderField.new(["Nominal","amount"], headers.size, Setup::Type::AMOUNT, false, 8)
			headers << HeaderField.new("Sell cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new(["Nominal","amount"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Reference", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Trade date", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Maturity", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Deal exchange rate", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("Forward mark to market", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("P&L (USD)", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["% Acc.","% Liq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			new_positions = []
			present = get_table(headers, offset, bottom, page_end, nil, nil) do |table|
				table.rows.each.with_index do |r,i|
					results = table.headers.map{|h| h.results[i].result}
					new_positions << Position.new( 
						title = results[2],
						to_number(results[7]), 
						1.0,
						to_number(results[7]))
				end
			end
			if present
				total = SingleField.new("Total",[Setup::Type::AMOUNT])
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0].result)
				return new_positions
			else
				puts "Unable to read Foreign Exchange table".red
				return false
			end
		end
		puts " - No Foreign Exhange for this account"
		return false
	end
end