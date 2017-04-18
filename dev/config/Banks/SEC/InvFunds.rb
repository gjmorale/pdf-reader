class SEC::InvFunds < SECAssetTable
	def load
		@name = "fondos de inversión"
		@title = Field.new("FONDOS DE INVERSION")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("NOMBRE FONDO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new(["NUMERO","CUOTA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR PROMEDIO","COMPRA ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR CUOTA","ACTUAL ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO","ACTUAL ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MAYOR O","MENOR VALOR"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		6
		@quantity_index = 	3
		@value_index = 		7
		@total_index = 		1
	end
end