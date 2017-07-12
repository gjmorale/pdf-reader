class MON::FixedIncomeCLP < MON::AssetTable
	def load
		@name = "fondos de renta fija en clp"
		@title = Field.new("FONDOS RENTA FIJA NACIONAL")
		@table_end = Field.new("Total")
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

class MON::FixedIncomeUSD < MON::AssetTable
	def load
		@name = "fondos de renta fija internacional"
		@title = Field.new("FONDOS RENTA FIJA INTERNACIONAL")
		@table_end = Field.new("Total")
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

