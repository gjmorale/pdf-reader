class GovSecs < MSAssetTable
	def load
		@name = "gov. securities"
		@title = Field.new("GOVERNMENT SECURITIES")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, true)
			headers << HeaderField.new("Face Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Unit Cost","Adj Unit Cost"], headers.size, BankUtils.to_arr(Setup::Type::FLOAT, 2), false)
			headers << HeaderField.new("Unit Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Total Cost","Adj Total Cost"], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new(["Est Ann Income","Accrued Interest"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("GOVERNMENT SECURITIES",
			[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Custom::AMOUNT_W_TERM, 
			Setup::Type::AMOUNT], 
			5, Setup::Align::LEFT)
		@offset = nil
		@page_end = nil
		@price_index = 		4
		@quantity_index = 	2
		@value_index = 		6
		@ai_index = 		8
		@total_index = 		3
		@total_ai_index = 	5
		@total_column = 	1
		@position_parser = 'CUSIP'
	end
end
