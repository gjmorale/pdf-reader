
class Stocks < AssetTable
	def load
		@name = "stocks"
		@title = Field.new("STOCKS")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("STOCKS",[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Custom::AMOUNT_W_TERM, 
			Setup::Type::AMOUNT, 
			Setup::Type::PERCENTAGE], 
			6, Setup::Align::LEFT)
		@offset = nil
		@page_end = nil
		@price_index = 		4
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		2
		@total_column = 	1
	end
end

class StocksAlt < AssetTable
	def load
		@name = "stock alternatives"
		@title = Field.new("STOCKS")
		@table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
		@headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
		@skips = ['.*(?:Asset Class:).*']
		@total = SingleField.new("STOCKS",[Setup::Type::PERCENTAGE, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT,  
			Setup::Type::AMOUNT, 
			Setup::Type::PERCENTAGE], 
			6, Setup::Align::LEFT)
		@offset = nil
		@page_end = nil
		@price_index = 		2
		@quantity_index = 	1
		@value_index =		4
		@total_index = 		2
		@total_column = 	1
	end
end