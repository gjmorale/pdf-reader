class PrivateEquity < AssetTable
	def load
		@name = "private equity"
		@title = Field.new('PRIVATE EQUITY')
		@table_end = [Field.new("PRIVATE EQUITY"),Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)]
		@headers = []
		headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
		headers << HeaderField.new("Commitment", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Contributions","to Date"], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new(["Remaining","Commitment"], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new("Distributions", headers.size, Setup::Type::AMOUNT, false)
		headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new(["Est Value","+ Distributions"], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new('PRIVATE EQUITY',
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			4, Setup::Align::LEFT)
		@price_default = 	0.0
		@quantity_index = 	2
		@value_index = 		5
		@total_index = 		4
	end
end
