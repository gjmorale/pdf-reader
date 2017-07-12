class SEC::BondsCLP < SECAssetTable
	def load
		@name = "instrumentos de deuda en clp"
		@title = Field.new("INSTRUMENTOS DE DEUDA NACIONALES")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("NOMINALES", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("VENCIMIENTO", headers.size, Setup::Type::DATE, false)
			headers << HeaderField.new(["TASA","COMPRA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR A","TASA COMPRA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["TASA","MERCADO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR A TASA","MERCADO"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		8
		@quantity_index = 	4
		@value_index = 		9
		@total_index = 		1
	end
end