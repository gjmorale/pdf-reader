
class PER::ENG::Cash < PER::AssetTable
	def load
		@name = "cash"
		@offset = Field.new("CASH, MONEY FUNDS, AND BANK DEPOSITS")
		@table_end = Field.new("Total Money Market")
		@headers = []
			headers << HeaderField.new("Description",headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity",headers.size, Custom::NUM3)
			headers << HeaderField.new(["Opening","Balance"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Closing","Balance"],headers.size, Custom::NUM2,true,4)
			headers << HeaderField.new(["Accrued","Income"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Income","This Year"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["30-Day","Yield"],headers.size, Setup::Type::PERCENTAGE,false,4)
		@total = SingleField.new("TOTAL CASH, MONEY FUNDS, AND BANK DEPOSITS",
			BankUtils.to_arr(Setup::Type::AMOUNT,4))
		@page_end = 		Field.new("Page ¶¶ of ")
		@label_index = 		0
		@price_default = 	"1.0"
		@quantity_index = 	3
		@value_index = 		3
		@total_index = 		1
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		1
	end

	def each_result_do results, row=nil
		results[label_index].strip
	end
end



