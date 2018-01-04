class MBI::EstrategiasAlternativas < MBI::AssetTable
	def load
		@name = "estrategias alternativas baja volatilidad"
		@offset = Field.new("Estrategias Alternativas Baja Volatilidad")
		@table_end = Field.new("Total Estrategias Alternativas Baja Volatilidad")
		@headers = []
			headers << HeaderField.new("Detalle Instrumentos", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Emisor", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Moneda", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new("Fecha Vcto.", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Dur.", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Precio Prom.","Compra"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Precio","Mercado"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valor Mercado","($$)"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Valor Mercado","(US$)"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Dividendos /","Cupones"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Rentab.","(%)"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["%","Cartera"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("Total Estrategias Alternativas Baja Volatilidad",
			BankUtils.to_arr(Setup::Type::INTEGER,2)+[Setup::Type::PERCENTAGE])
		@label_index = 		0
		@price_index = 		7
		@quantity_index = 	3
		@value_index = 		8
		@total_index = 		0
		@require_rows = 	true
		@require_offset = 	true
	end
end