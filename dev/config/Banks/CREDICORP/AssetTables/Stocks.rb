class CrediCorp::StocksCLP < CrediCorp::AssetTable
	def load
		@name = "acciones en clp"
		@offset = Field.new("ACCIONES")
		@table_end = Field.new("TOTAL¶ACCIONES / CLP")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO", headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("LIBRE", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("EN GARANTÍA", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO A PLAZO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO PRÉSTAMO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("TOTAL", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("COMPRA", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("CIERRE", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("VALOR MERCADO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("PORCENTAJE DE CARTERA", headers.size, Setup::Type::PERCENTAGE)
			headers << HeaderField.new("RENTABILIDAD (%)", headers.size, Setup::Type::PERCENTAGE)
		@total = SingleField.new("TOTAL¶ACCIONES / CLP",
			[Setup::Type::AMOUNT])
		@price_index = 		7
		@quantity_index = 	1
		@value_index = 		8
		@total_index = 		0
	end
end

class CrediCorp::StocksUSD < CrediCorp::AssetTable
	def load
		@name = "acciones en usd"
		@offset = [Field.new("ACCIONES"), Field.new("TOTAL¶ACCIONES / CLP")]
		@table_end = Field.new("TOTAL¶ACCIONES / USD")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO", headers.size, Custom::ASSET_LABEL, true)
			headers << HeaderField.new("LIBRE", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("EN GARANTÍA", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO A PLAZO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO PRÉSTAMO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("TOTAL", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("COMPRA", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("CIERRE", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("VALOR MERCADO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("PORCENTAJE DE CARTERA", headers.size, Setup::Type::PERCENTAGE)
			headers << HeaderField.new("RENTABILIDAD (%)", headers.size, Setup::Type::PERCENTAGE)
		@total = SingleField.new("TOTAL¶ACCIONES / USD",
			[Setup::Type::AMOUNT])
		@price_index = 		7
		@quantity_index = 	1
		@value_index = 		8
		@total_index = 		0
	end
end


			
