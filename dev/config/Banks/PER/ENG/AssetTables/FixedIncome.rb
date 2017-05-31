class PER::ENG::Bonds < PER::AssetTable
	def load
		@name = "corporative bonds"
		@offset = Field.new("Corporative Bonds")
		@table_end = Field.new("Total Corporative Bonds")
		@headers = []
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3)
			headers << HeaderField.new("Market Price", headers.size, Custom::NUM4, true)
			headers << HeaderField.new("Market Value", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Accured","Interests"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Estimated","Annual Income"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Estimated","Yield"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@skips = ['Original Costa Base: \$[0-9,.\s]+']
		@total = SingleField.new("Total Corporative Bonds",
			BankUtils.to_arr(Setup::Type::AMOUNT,2))
		@page_end = 		Field.new("Page ¶¶ of ")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		3
		@total_index = 		0
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		2
		@total_column = 	0
	end

	def parse_position str, type
		if str =~ /ISIN [A-Z0-9]{12}/
			str.split(';').reverse
		else
			[str,nil]
		end
	end
end
