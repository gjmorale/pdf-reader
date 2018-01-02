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

class PER::ENG::ETFSAlt < PER::AssetTable
	def load
		@name = "etfs"
		@offset = Field.new("EXCHANGE-TRADED PRODUCTS")
		@table_end = Field.new("TOTAL EXCHANGE-TRADED PRODUCTS")
		@headers = []
			headers << HeaderField.new("Date Acquired", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3, true)
			headers << HeaderField.new("Unit Cost", headers.size, Custom::NUM4)
			headers << HeaderField.new("Cost Basis", headers.size, Custom::NUM2)
			headers << HeaderField.new("Market Price", headers.size, Custom::NUM4)
			headers << HeaderField.new("Market Value", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Unrealized","Gain/Loss"], headers.size, Custom::NUM2)
			headers << HeaderField.new(["Estimated","Annual Income"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Estimated","Yield"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("TOTAL EXCHANGE-TRADED PRODUCTS",
			BankUtils.to_arr(Setup::Type::AMOUNT,4))
		@page_end = 		Field.new("Page ¶¶ of ")
		@price_index = 		4
		@quantity_index = 	1
		@value_index = 		5
		@total_index = 		1
		@total_column = 	0
		@require_rows = 	true
		@require_offset = 	true
		@position_parser = 	/(?<=Security Identifier: ).+$/
	end

	def parse_position str, type
		str.split(';').reverse
	end

	def filter_text options
		#puts options.join(';').red
		text = options.select{|o| 
			not o.empty? and
			o =~ /.*[A-Z]{2}.*/ and
			not (o =~ /(Total|CUSIP|ISIN|Option|Cash|^\s*$)/)
		}.each{|o| o.strip!}.join(';')
		code = text.match /(?<=Security Identifier: )[A-Z0-9]+/
		text = text.gsub(/;\s?Security[^;]+($|;)/,' ')
		text << ";#{code}" if code
		text
	end
end


