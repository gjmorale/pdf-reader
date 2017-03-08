HSBC.class_eval do
	def private_equity_for account
		new_positions = []
		search = Field.new("Private Equity - Portfolio #{account.code} - #{account.name}")
		if search.execute @reader
			pos = nil
			new_positions += pos if(pos = get_private_funds)
			return new_positions
		else
			puts " - No Private Equity for this account"
			return nil
		end
	end

	def get_private_funds
		offset = Field.new("Private Equity Funds")
		bottom = Field.new("Total Private Equity")
		headers = []
		headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
		headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
		headers << HeaderField.new(["Initial Commitment","Remaining Commitment","% Called"], headers.size, [Setup::Type::AMOUNT,Setup::Type::AMOUNT,Setup::Type::PERCENTAGE], false, 6)
		headers << HeaderField.new(["Total Called","Tot Distributed"], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
		headers << HeaderField.new(["Market price","Fund report date"], headers.size, [Setup::Type::AMOUNT,Setup::Type::DATE], false, 4)
		headers << HeaderField.new("Fund market value", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new(["TVPI","RVPI"], headers.size, to_arr(Setup::Type::FLOAT,2), false, 4)
		headers << HeaderField.new("Mkt. value", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new("Mkt. value (USD)", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new(["% Acc.","% Pri. Eq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		table = Table.new(headers, bottom, offset)
		table.execute @reader
		#table.print_results
		new_positions = []
		table.rows.each.with_index do |r,i|
			results = table.headers.map{|h| h.results[i].result}
			titles = parse_position results[2], 'Reference'

			new_positions << Position.new(titles[0], 
				1.0,
				to_number(results[9]), 
				to_number(results[9]), 
				titles[1])
		end
		total = SingleField.new("Total Private Equity",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		total.execute @reader
		#total.print_results
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		check acumulated, to_number(total.results[0].result)
		return new_positions
	end
end
