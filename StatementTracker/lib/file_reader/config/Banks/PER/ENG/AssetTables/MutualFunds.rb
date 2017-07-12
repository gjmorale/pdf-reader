class PER::ENG::MutualFunds < PER::ENG::AssetTable
	def load
		@name = "mutual funds"
		@offset = Field.new("MUTUAL FUNDS")
		@table_end = Field.new("TOTAL MUTUAL FUNDS")
		@headers = []
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3)
			headers << HeaderField.new("Market Price", headers.size, Custom::NUM4, true)
			headers << HeaderField.new("Market Value", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Estimated","Yield"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("TOTAL MUTUAL FUNDS",
			[Setup::Type::AMOUNT])
		@page_end = 		Field.new("Page ¶¶ of ")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		3
		@total_index = 		0
		@require_rows = 	true
		@require_offset = 	true
		@label_index = 		0
		@position_parser = 	/(?<=Security Identifier:)\s?.+$/
	end
end


