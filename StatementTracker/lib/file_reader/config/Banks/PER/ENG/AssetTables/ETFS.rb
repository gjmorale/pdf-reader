class PER::ENG::ETFS < PER::ENG::AssetTable
	def load
		@name = "etfs"
		@offset = Field.new("EXCHANGE-TRADED PRODUCTS")
		@table_end = Field.new("TOTAL EXCHANGE-TRADED PRODUCTS")
		@headers = []
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3, true)
			headers << HeaderField.new("Market Price", headers.size, Custom::NUM4)
			headers << HeaderField.new("Market Value", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Estimated","Annual Income"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Estimated","Yield"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("TOTAL EXCHANGE-TRADED PRODUCTS",
			BankUtils.to_arr(Setup::Type::AMOUNT,2))
		@page_end = 		Field.new("Page ¶¶ of ")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		3
		@total_index = 		0
		@require_rows = 	true
		@require_offset = 	true
		@label_index = 		0
		@position_parser = 	/(?<=Security Identifier: ).+$/
	end
end


