class MS::MutualFunds < MSAssetTable
	def load
		@name = "mutual funds"
		@title = Field.new("MUTUAL FUNDS")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
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
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("MUTUAL FUNDS",
			[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Custom::AMOUNT_W_TERM, 
			Setup::Type::AMOUNT, 
			Setup::Type::FLOAT], 
			4, Setup::Align::LEFT)
		@offset = 			nil
		@page_end = 		nil
		@price_index = 		4
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		2
		@total_column = 	1
		@title_dump = /(Long Term Reinvestments|Short Term Reinvestments|Cumulative\ *Cash\ *Distributions|Total Purchases vs Market Value|Net Value Increase\/\(Decrease\))/
	end
end

class MS::MutualFundsAlt < MSAssetTable
	def load
		@name = "mutual funds alternative"
		@title = Field.new("MUTUAL FUNDS")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Quantity", headers.size, Custom::TOTAL_AMOUNT, true)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("MUTUAL FUNDS",
			[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Custom::AMOUNT_W_TERM, 
			Setup::Type::AMOUNT, 
			Setup::Type::FLOAT], 
			4, Setup::Align::LEFT)
		@offset = 			nil
		@page_end = 		nil
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		4
		@total_index = 		2
		@title_dump = /(Purchases|Reinvestments|Total .* vs Market Value|Cumulative\ *Cash\ *Distributions|Net Value Increase\/\(Decrease\))+/i
	end

	def get_results
		new_positions = []
		label = share_price = false
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if results[price_index] != Result::NOT_FOUND
					label = title_dump ? results[0].inspect.gsub(title_dump, '') : results[0]
					share_price = BankUtils.to_number(results[price_index])
				end
				if results[7] != Result::NOT_FOUND
					new_positions << Position.new(label, 
							BankUtils.to_number(results[quantity_index]), 
							share_price, 
							BankUtils.to_number(results[value_index]))
				end
			end
		end
		if present
			return new_positions
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end
end
