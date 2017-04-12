class FixedIncome < MSAssetTable
	def load
		@name = "fixed income"
		@title = Field.new("CORPORATE FIXED INCOME")
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
		@total = SingleField.new("CORPORATE FIXED INCOME",
			[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Custom::AMOUNT_W_TERM, 
			Setup::Type::AMOUNT], 
			6, Setup::Align::LEFT)
		@offset = 			nil
		@page_end = 		nil
		@price_index = 		4
		@quantity_index = 	2
		@value_index = 		6
		@ai_index = 		8
		@total_index = 		3
		@total_ai_index = 	5
		@total_column = 	1
		@unfinished_regex =	/CUSIP/
		@position_parser = 	'CUSIP'
	end
end

class FixedIncomeAlt < MSAssetTable
	def load
		@name = "fixed income alternative"
		@title = Field.new("CORPORATE FIXED INCOME")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Face Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Unit Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Total Cost","Adj Total Cost"], headers.size, BankUtils.to_arr(Setup::Type::FLOAT, 2), false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new(["Est Ann Income","Accrued Interest"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, true,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("CORPORATE FIXED INCOME",
			[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT,  
			Setup::Type::AMOUNT], 
			6, Setup::Align::LEFT)
		@offset = 			nil
		@page_end = 		nil
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		4
		@ai_index = 		6
		@total_index = 		3
		@total_ai_index = 	5
		@total_column = 	1
		@unfinished_regex =	/CUSIP/
		@position_parser = 	'CUSIP'
	end
end