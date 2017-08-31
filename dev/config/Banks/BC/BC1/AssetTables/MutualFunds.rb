class BC1::MutualFundsCLP < BC1::AssetTable
	def load
		@title_limit = 2
		@name = "fondos mutuos en clp"
		@title = Field.new("Fondos Mutuos en Pesos Chilenos: Vigentes al")
		@table_end = Field.new("Monto Total Vigente en Pesos Chilenos:")
		@headers = []
			headers << HeaderField.new("Clasificación", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Fondo Mutuo", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Serie", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Características", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Cuenta", headers.size, Custom::FIN_RUT, false)
			headers << HeaderField.new("Nº Cuotas", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Valor Cuota ($)", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Monto ($)", headers.size, Setup::Type::AMOUNT, true)
		@total = SingleField.new("Monto Total Vigente en Pesos Chilenos:",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@label_index = 		1
		@price_index = 		6
		@quantity_index = 	5
		@value_index = 		7
		@total_index = 		0
	end
end

class BC1::MutualFundsUSD < BC1::AssetTable
	def load
		@name = "fondos mutuos en usd"
		@title = Field.new("Fondos Mutuos en Dólares: Vigentes al")
		@table_end = Field.new("Monto Total Vigente en Dólares:")
		@headers = []
			headers << HeaderField.new("Clasificación", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Fondo Mutuo", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Serie", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Características", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Cuenta", headers.size, Custom::FIN_RUT, false)
			headers << HeaderField.new("Nº Cuotas", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new(["Valor Cuota","(US$)"], headers.size, Custom::FLOAT4, false, 4)
			headers << HeaderField.new("Monto (US$)", headers.size, Setup::Type::AMOUNT, true)
		@total = SingleField.new("Monto Total Vigente en Dólares:",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@label_index = 		1
		@price_index = 		6
		@quantity_index = 	5
		@value_index = 		7
		@total_index = 		0
		@alt_currency = 	:usd
	end
end

