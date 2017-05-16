class CrediCorp::MutualFundsCLP < CrediCorp::AssetTable
	def load
		@name = "fondos mutuos clp"
		@offset = Field.new("FONDOS MUTUOS")
		@table_end = Field.new("TOTAL¶FONDOS¶MUTUOS / CLP")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO",headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("SERIE",headers.size, Custom::SERIES_CODE)
			headers << HeaderField.new("LIBRES",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("EN GARANTÍA",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("PROMEDIO APORTE",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("ACTUAL",headers.size, Setup::Type::FLOAT,false,1,Setup::Align::BOTTOM,60)
			headers << HeaderField.new("VALOR ACTUAL",headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("RENTABILIDAD (%)",headers.size, Setup::Type::PERCENTAGE)
		@skips = ['FONDO\s?(MUTUO|DE\s?INVERSI[OÓ]N)\s?(CREDICORP|IM TRUST).*']
		@total = SingleField.new("TOTAL¶FONDOS¶MUTUOS / CLP",
			[Setup::Type::AMOUNT])
		@page_end = 		Field.new("Reporte de Inversiones Provisorio")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		0
	end
end

class CrediCorp::MutualFundsUSD < CrediCorp::AssetTable
	def load
		@name = "fondos mutuos usd"
		@offset = [Field.new("FONDOS MUTUOS"),Field.new("TOTAL¶FONDOS¶MUTUOS / CLP")]
		@table_end = Field.new("TOTAL¶FONDOS¶MUTUOS / USD")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO",headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("SERIE",headers.size, Custom::SERIES_CODE)
			headers << HeaderField.new("LIBRES",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("EN GARANTÍA",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("PROMEDIO APORTE",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("ACTUAL",headers.size, Setup::Type::FLOAT,false,1,Setup::Align::BOTTOM,60)
			headers << HeaderField.new("VALOR ACTUAL",headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("RENTABILIDAD (%)",headers.size, Setup::Type::PERCENTAGE)
		@skips = ['FONDO\s?(MUTUO|DE\s?INVERSI[OÓ]N)\s?(CREDICORP|IM TRUST).*']
		@total = SingleField.new("TOTAL¶FONDOS¶MUTUOS / USD",
			[Setup::Type::AMOUNT])
		@page_end = 		Field.new("Reporte de Inversiones Provisorio")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		0
	end
end

			


