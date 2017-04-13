class SEC::MutualFunds < SECAssetTable
	def load
		@verbose = true
		@name = "fondos mutuos"
		@title = Field.new("FONDOS MUTUOS")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("NOMBRE FONDO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("GESTIONADO", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("ES 57 BIS", headers.size, Custom::SI_NO, false)
			headers << HeaderField.new(["NUMERO","CUOTA"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new(["VALOR PROMEDIO","COMPRA ($)"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO ($)"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new(["VALOR CUOTA","ACTUAL ($)"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new(["SALDO","ACTUAL ($)"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new(["MAYOR O","MENOR VALOR"], headers.size, Setup::Type::LABEL, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@offset = 			Field.new("FONDOS MUTUOS NACIONALES - CLP")
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 	4
		@value_index = 		8
		@total_index = 		1
	end
end