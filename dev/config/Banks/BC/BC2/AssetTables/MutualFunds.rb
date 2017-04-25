class BC2::MutualFunds < BC2::AssetTable
	def load
		@name = "fondos mutuos"
		@title = Field.new("FONDOS MUTUOS")
		@table_end = Field.new("Total FM ")
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