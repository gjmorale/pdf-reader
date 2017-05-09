class BC2::Stocks < BC2::AssetTable
	def load
		@name = "acciones"
		@title = Field.new("Acciones de Soc. Anonimas Abiertas")
		@table_end = Field.new("Total Acciones de Soc. Anonimas Abiertas")
		@headers = []
			headers << HeaderField.new("Acción", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT2, false)
			headers << HeaderField.new("Total", headers.size, Setup::Type::FLOAT, false)
			headers << HeaderField.new(["%","Patrimonio"], headers.size, Custom::FLOAT2, false, 4)
			headers << HeaderField.new(["%","Rentabilidad"], headers.size, Custom::FLOAT2, false, 4)
		@total = SingleField.new("Total Acciones de Soc. Anonimas Abiertas",
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