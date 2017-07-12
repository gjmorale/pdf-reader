class ManagedFutures < MSAssetTable
	def load
		@name = "managed futures"
		@title = Field.new('MANAGED FUTURES')
		@table_end = [Field.new("MANAGED FUTURES"),Field.new("REAL ESTATE"),Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)]
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Setup::Type::DATE, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","NAV"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new('MANAGED FUTURES',
					[Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT,], 
					4, Setup::Align::LEFT)
		@offset = 			nil
		@page_end = 		nil
		@price_index = 		1
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		1
		@total_column = 	nil
	end
end