
class HSBC::MutualFunds < HSBCAssetTable
	def load
		@name = "hedge funds"
		@title = Field.new("Hedge Funds#{account_title}")
		@table_end = Field.new("Total Hedge Funds")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new("Maturity", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Custom::LONG_AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% HF."], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total Hedge Funds",[Setup::Type::AMOUNT,
			Setup::Type::PERCENTAGE])
		@offset = Field.new("Hedge Funds")
		@page_end = Field.new(" Account: ")

		@price_index = 		5
		@quantity_index = 	1
		@value_index = 		7
		@total_index = 		0
		@position_parser = 	'ISIN'
	end
end