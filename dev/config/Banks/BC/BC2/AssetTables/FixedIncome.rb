class BC2::FixedIncome < BC2::AssetTable
	def load
		@name = "renta fija"
		@title = Field.new("Otras Inv. de Renta Fija")
		@table_end = Field.new("Total Otras Inv. de Renta Fija")
		@headers = []
			headers << HeaderField.new("Acción", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total Otras Inv. de Renta Fija",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5 #In USD
		@quantity_index = 	2
		@value_index = 		6 #In CLP
		@total_index = 		1
		#USD usd 	:= v/(q*p)
		#CLP clp_p 	:= usd*p
	end
end

class BC2::FixedIncomeNac < BC2::AssetTable
	def load
		@name = "renta fija nacional"
		@title = Field.new("Cuotas de Fondos de inversión Nacionales")
		@table_end = Field.new("Total Cuotas de Fondos de inversión Nacionales")
		@headers = []
			headers << HeaderField.new("Acción", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total Cuotas de Fondos de inversión Nacionales",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5 #In USD
		@quantity_index = 	2
		@value_index = 		6 #In CLP
		@total_index = 		1
		#USD usd 	:= v/(q*p)
		#CLP clp_p 	:= usd*p
	end
end
class BC2::FixedIncomeAlt < BC2::AssetTable
	def load
		@name = "renta fija alternativa"
		@title = Field.new("Inversión Alternativa")
		@table_end = Field.new("Total Inversión Alternativa")
		@headers = []
			headers << HeaderField.new("Acción", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total Inversión Alternativa",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5 #In USD
		@quantity_index = 	2
		@value_index = 		6 #In CLP
		@total_index = 		1
		#USD usd 	:= v/(q*p)
		#CLP clp_p 	:= usd*p
	end
end