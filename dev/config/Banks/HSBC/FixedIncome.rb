
class HSBC::FixedIncome < HSBCAssetTable
	def load
		@name = "fixed income"
		@title = Field.new("Fixed Income#{account_title}")
		@table_end = Field.new("Total Fixed Income")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Nominal", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 5)
			headers << HeaderField.new("Region", headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Rating","Coupon"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Custom::LONG_AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, BankUtils.to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% FI"], headers.size, BankUtils.to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@total = SingleField.new("Total Fixed Income",[Setup::Type::AMOUNT,
			Setup::Type::PERCENTAGE])
		@offset = [Field.new("Fixed Income Mutual Funds"), Field.new("Bonds")]
		@page_end = Field.new(" Account: ")

		@price_index = 		7
		@quantity_index = 	1
		@value_index = 		9
		@total_index = 		0
		@position_parser = 	'ISIN'
	end
end