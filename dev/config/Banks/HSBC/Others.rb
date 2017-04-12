
class HSBC::Others < HSBCAssetTable
	def load
		@name = "other investments"
		@title = Field.new("Others#{account_title}")
		@table_end = Field.new("Total Others")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Setup::Type::AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Others."], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total Others",[Setup::Type::AMOUNT,
			Setup::Type::PERCENTAGE])
		@offset = Field.new("Other Mutual Funds")
		@page_end = Field.new(" Account: ")

		@price_index = 		5
		@quantity_index = 	1
		@value_index = 		7
		@total_index = 		0
		@position_parser = 	'ISIN'
	end
end