class HSBC::CurrentAccount < HSBCAssetTable
	def load
		@name = "current account liquidity"
		@title = Field.new("Liquidity and Money Market#{account_title}")
		@table_end = Field.new("Total")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Liq."], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total",[Setup::Type::AMOUNT])
		@offset = Field.new("Current Accounts")
		@page_end = Field.new(" Account: ")

		@price_default = 	1.0
		@quantity_index = 	1
		@value_index = 		4
		@total_index = 		0
		@position_parser = 	'ACCOUNT'
	end
end

class HSBC::FX < HSBCAssetTable
	def load
		@name = "fx liquidity"
		#@title = Field.new("Liquidity and Money Market#{account_title}")
		@table_end = Field.new("Total")
		@headers = []
			headers << HeaderField.new("Sell cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new(["Nominal","amount"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Reference", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Trade date", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Maturity", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Deal exchange rate", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("Forward mark to market", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("P&L (USD)", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["% Acc.","% Liq."], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total",[Setup::Type::AMOUNT])
		@offset = Field.new("Foreign Exchange")
		@page_end = Field.new(" Account: ")

		@price_default = 	1.0
		@quantity_index = 	7
		@value_index = 		7
		@total_index = 		0
		@position_parser = 	'ACCOUNT'
	end
end