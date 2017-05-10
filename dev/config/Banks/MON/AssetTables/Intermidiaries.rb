class MON::Intermidiaries < MON::AssetTable
	def load
		@name = "intermediarios financieros"
		@title = Field.new("INTERMEDIACIÓN FINANCIERA")
		@table_end = [Field.new("Total"), Field.new("No registra posiciones")]
		@headers = []
			headers << HeaderField.new("Emisor", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Instrumento", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new(["Porcentaje","Total"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Cat","Riesgo"], headers.size, Setup::Type::LABEL, false, 4)
			headers << HeaderField.new("Moneda", headers.size, Setup::Type::CURRENCY)
			headers << HeaderField.new(["Monto","Nominal"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Fecha","Vencimiento"], headers.size, Setup::Type::DATE, false, 4)
			headers << HeaderField.new(["Tasa","Mercado"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valor Actual","De Mercado ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Duration", headers.size, Setup::Type::DATE)
		@total = SingleField.new("Total",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT])
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@price_index = 		7
		@quantity_index = 	5
		@value_index = 		8
		@total_index = 		1
	end
end