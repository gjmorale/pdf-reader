class MON::MutualFunds < MON::AssetTable
	def load
		@name = "fondos mutuos"
		@title = Field.new("FONDOS MUTUOS")
		@table_end = [Field.new("No registra posiciones"), Field.new("Total")]
		@headers = []
			headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Descripción", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Precio Prom","Compra ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Costo","Histórico ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Precio","Cierre ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valor","Mercado ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Retorno","Nominal"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("Total",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT])
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@price_index = 		5
		@quantity_index = 	2
		@value_index = 		6
		@total_index = 		1
	end
end