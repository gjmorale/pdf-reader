class SEC::MutualFundsCLP < SECAssetTable
	def load
		@name = "fondos mutuos en clp"
		@title = [Field.new("FONDOS MUTUOS NACIONALES - CLP"),Field.new("FONDOS SECURITY - CLP")]
		@table_end = [Field.new("TOTAL"), Field.new("FONDOS DE INVERSION")]
		@headers = []
			headers << HeaderField.new("NOMBRE FONDO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("ES 57 BIS", headers.size, Custom::SI_NO, false)
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
		@price_index = 		7
		@quantity_index = 	4
		@value_index = 		8
		@total_index = 		1
	end
end

class SEC::MutualFundsUSD < SECAssetTable
	def load
		@name = "fondos mutuos en usd"
		@title = Field.new("FONDOS SECURITY - USD")
		@table_end = [Field.new("TOTAL"), Field.new("FONDOS DE INVERSION")]
		@headers = []
			headers << HeaderField.new("NOMBRE FONDO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("ES 57 BIS", headers.size, Custom::SI_NO, false)
			headers << HeaderField.new(["NUMERO","CUOTA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR PROMEDIO","COMPRA (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR CUOTA","ACTUAL (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO","ACTUAL (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MAYOR O","MENOR VALOR (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 	4
		@value_index = 		8
		@total_index = 		1
		@alt_currency =		:usd
	end
end

class SEC::MutualFundsOthers < SECAssetTable
	def load
		@name = "otros fondos mutuos"
		@title = Field.new("OTROS FONDOS - USD")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("NOMBRE FONDO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("ES 57 BIS", headers.size, Custom::SI_NO, false)
			headers << HeaderField.new(["NUMERO","CUOTA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR PROMEDIO","COMPRA (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR CUOTA","ACTUAL (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO","ACTUAL (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MAYOR O","MENOR VALOR (USD)"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 	4
		@value_index = 		8
		@total_index = 		1
		@alt_currency =		:usd
	end
end

class SEC::MutualFundsForeign < SECAssetTable
	def load
		@name = "fondos mutuos extranjeros"
		@title = Field.new("FONDOS MUTUOS")
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