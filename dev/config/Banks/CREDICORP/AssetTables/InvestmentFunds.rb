class CrediCorp::InvestmentFundsCLP < CrediCorp::AssetTable
	def load
		@name = "fondos de inversion clp"
		@offset = Field.new("FONDOS DE INVERSIÓN")
		@table_end = Field.new("TOTAL¶FONDOS¶DE¶INVERSIÓN / CLP")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO",headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("SERIE",headers.size, Custom::SERIES_CODE)
			headers << HeaderField.new("LIBRES",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("EN GARANTÍA",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("PROMEDIO APORTE",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("ACTUAL",headers.size, Setup::Type::FLOAT,false,1,Setup::Align::BOTTOM,60)
			headers << HeaderField.new("VALOR ACTUAL",headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("RENTABILIDAD (%)",headers.size, Setup::Type::PERCENTAGE)
		@skips = ['FONDO\s?(MUTUO|DE\s?INVERSI[OÓ]N)\s?(CREDICORP|IM TRUST|RENTA FIJA).*']
		@total = SingleField.new("TOTAL¶FONDOS¶DE¶INVERSIÓN / CLP",
			[Setup::Type::AMOUNT])
		@page_end = 		Field.new("Reporte de Inversiones Provisorio")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		0
	end
end

class CrediCorp::InvestmentFundsUSD < CrediCorp::AssetTable
	def load
		@name = "fondos de inversion usd"
		@offset = [Field.new("FONDOS DE INVERSIÓN"),Field.new("TOTAL¶FONDOS¶DE¶INVERSIÓN / CLP")]
		@table_end = Field.new("TOTAL¶FONDOS¶DE¶INVERSIÓN / USD")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO",headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("SERIE",headers.size, Custom::SERIES_CODE)
			headers << HeaderField.new("LIBRES",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("EN GARANTÍA",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("PROMEDIO APORTE",headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("ACTUAL",headers.size, Setup::Type::FLOAT,false,1,Setup::Align::BOTTOM,60)
			headers << HeaderField.new("VALOR ACTUAL",headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("RENTABILIDAD (%)",headers.size, Setup::Type::PERCENTAGE)
		@skips = ['FONDO\s?(MUTUO|DE\s?INVERSI[OÓ]N)\s?(CREDICORP|IM TRUST|RENTA FIJA).*']
		@total = SingleField.new("TOTAL¶FONDOS¶DE¶INVERSIÓN / USD",
			[Setup::Type::AMOUNT])
		@page_end = 		Field.new("Reporte de Inversiones Provisorio")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		0
	end
end