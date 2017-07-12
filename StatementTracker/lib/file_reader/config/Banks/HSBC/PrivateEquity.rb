class HSBC::PrivateEquity < HSBCAssetTable
	def load
		@name = "private equity"
		@title = Field.new("Private Equity#{account_title}")
		@table_end = Field.new("Total Private Equity")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Initial Commitment","Remaining Commitment","% Called"], headers.size, [Setup::Type::AMOUNT,Setup::Type::AMOUNT,Setup::Type::PERCENTAGE], false, 6)
			headers << HeaderField.new(["Total Called","Tot Distributed"], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Market price","Fund report date"], headers.size, [Setup::Type::AMOUNT,Setup::Type::DATE], false, 4)
			headers << HeaderField.new("Fund market value", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["TVPI","RVPI"], headers.size, BankUtils.to_arr(Setup::Type::FLOAT,2), false, 4)
			headers << HeaderField.new("Mkt. value", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Mkt. value (USD)", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["% Acc.","% Pri. Eq."], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total Private Equity",[Setup::Type::AMOUNT,
			Setup::Type::PERCENTAGE])
		@offset = Field.new("Private Equity Funds")
		@page_end = Field.new(" Account: ")

		@price_index = 		9
		@quantity_default = 1.0
		@value_index = 		9
		@total_index = 		0
		@position_parser = 	'Reference'
	end
end