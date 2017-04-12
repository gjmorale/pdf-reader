
class Equity < AssetTable
	def load
		@name = "equity"
		@title = Field.new("Equities#{account.title}")
		@table_end = Field.new("Total Equity")
		@headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty.", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new("Sector", headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Setup::Type::AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::FLOAT], false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Eq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
		@skips = ["Developed Europe ex UK","North America (US, CA)","Japan"].map{|s| Regexp.escape(s)}
		@total = SingleField.new("Total Equity",[Setup::Type::AMOUNT,
			Setup::Type::PERCENTAGE])
		@offset = Field.new("Equity Mutual Funds")
		@page_end = Field.new(" Account: ")

		@label_index = 		2
		@price_index = 		6
		@quantity_index = 	1
		@value_index = 		8
		@total_index = 		0
		@position_parser = 	'ISIN'
	end
end