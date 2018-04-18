class BC2::MutualFundsCP < BC2::AssetTable
	def load
		@name = "fondos mutuos"
		@title = Field.new("FM Deuda Menor a 90 días")
		@table_end = Field.new("Total FM Deuda Menor a 90 días")
		@headers = []
			headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("N° Cuotas", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total FM Deuda Menor a 90 días",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		1
	end
end

class BC2::MutualFundsMM < BC2::AssetTable
	def load
		@name = "fondos mutuos money market"
		@title = Field.new("Fondos Money Market")
		@table_end = Field.new("Total Fondos Money Market")
		@headers = []
			headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("N° Cuotas", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total Fondos Money Market",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		1
	end
end

class BC2::MutualFundsCal < BC2::AssetTable
	def load
		@name = "fondos mutuos calificados"
		@title = Field.new("FM Inversionistas Calificados")
		@table_end = Field.new("Total FM Inversionistas Calificados")
		@headers = []
			headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("N° Cuotas", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT4, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Patrimonio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Rentabilidad", headers.size, Custom::FLOAT2, false)
		@total = SingleField.new("Total FM Inversionistas Calificados",
			[Setup::Type::FLOAT,
			Setup::Type::FLOAT,
			Custom::FLOAT2], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		1
	end
end