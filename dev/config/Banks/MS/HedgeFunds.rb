class HedgeFunds < MSAssetTable
	def load
		@name = "hedge funds"
		@title = Field.new('HEDGE FUNDS')
		@table_end = Field.new("HEDGE FUNDS - SHARES")
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new(["Commitment/","Aggregate Investment"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Est Value","+ Redemptions","+ Distributions"], headers.size, Setup::Type::AMOUNT, false, 6)
			headers << HeaderField.new("Total Return", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = 			nil
		@offset = 			nil
		@page_end = 		nil
		@price_default = 	0.0
		@quantity_default = 0.0
		@value_index = 		3
		@total_index = 		nil
		@total_column = 	nil
	end
end

class HedgeFundShares < MSAssetTable
	def load
		@name = "hedge funds shares"
		@title = Field.new('HEDGE FUNDS - SHARES')
		@table_end = [Field.new("HEDGE FUNDS - SHARES"),Field.new('PRIVATE EQUITY')]
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
		@total = SingleField.new('HEDGE FUNDS - SHARES',
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