class SEC::Stocks < SECAssetTable
	def load
		@name = "acciones"
		@title = Field.new("ACCIONES NACIONALES")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("NOMBRE ACCION", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new(["ACCIONES","DISPONIBLES"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["TOTAL","EN GARANTIA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO A","PLAZO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["PRECIO PROMEDIO","COMPRA ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["PRECIO","CIERRE ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO","ACTUAL ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MAYOR O","MENOR VALOR"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		8
		@quantity_index = 	3
		@value_index = 		9
		@total_index = 		1
	end
end



class SEC::StockForeign < SECAssetTable
	def load
		@name = "acciones extranjeras"
		@title = Field.new("ACCIONES")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA)
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY)
			headers << HeaderField.new("CANTIDAD", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["PRECIO","COMPRA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["PRECIO","ACTUAL"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR DE","MERCADO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["UTILIDADES/","PÉRDIDAS"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALORIZACIÓN","EN USD"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALORIZACIÓN","EN $"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 4
		@value_index = 		11
		@total_index = 		1
	end
end