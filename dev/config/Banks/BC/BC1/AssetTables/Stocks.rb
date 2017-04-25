class BC1::StocksCLP < BC1::AssetTable
	def load
		@name = "acciones en clp"
		@title = Field.new("Acciones Nacionales: Vigentes al")
		@table_end = Field.new("Saldo de Acciones Nacionales:")
		@headers = []
			headers << HeaderField.new("Serie",headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Tipo Inst.",headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new(["Acciones","Disponibles (E)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Acciones en","Préstamo (F)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Garantías","Simultánea (G)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Garantías","Venta Corta (H)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Garantías","Forward (I)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Precio Mercado ($)",headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Saldo","Valorizado ($) (3)"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Acciones en","Simultánea"],headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Acciones en","Venta Corta"],headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("Saldo de Acciones Nacionales:",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 	2
		@value_index = 		8
		@total_index = 		0
	end
end
			
