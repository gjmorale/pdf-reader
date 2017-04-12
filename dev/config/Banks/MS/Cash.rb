class Cash < AssetTable
	def load
		@name = "cash"
		@title = Field.new("CASH, BANK DEPOSIT PROGRAM AND MONEY MARKET FUNDS")
		@table_end = [Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM),
				Field.new("BANK DEPOSITS")]
		@headers = []
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["7-Day","Current Yield %"], headers.size, Setup::Type::FLOAT, false, 4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("APY %", headers.size, Setup::Type::FLOAT, false)
		@skips = nil
		@total = nil
		@offset = 			nil
		@page_end = 		nil
		@price_default = 	1.0
		@quantity_index = 	1
		@value_index = 		1
		@total_index = 		1
		@total_column = 	nil
	end

	def check_results new_positions
		variant = ""
		variant_cue = SingleField.new("NET UNSETTLED PURCHASES/SALES", [Setup::Type::AMOUNT], 6, Setup::Align::LEFT)
		if @reader.read_next_field(variant_cue)
			variant_cue.execute @reader
			variant = " (PROJECTED SETTLED BALANCE)"
			new_positions << Position.new("NET UNSETTLED PURCHASES/SALES", 
				BankUtils.to_number(variant_cue.results[0].result), 
				1.0, 
				BankUtils.to_number(variant_cue.results[0].result))
		end
		total = SingleField.new("CASH, BDP, AND MMFs#{variant}",[Setup::Type::PERCENTAGE, Setup::Type::AMOUNT, Setup::Type::AMOUNT], 2, Setup::Align::BOTTOM)
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		table_total = total.execute(@reader) ? total.results[total_index].result : nil
		total.print_results if verbose and table_total
		BankUtils.check acumulated, BankUtils.to_number(table_total)
		return new_positions
	end
end