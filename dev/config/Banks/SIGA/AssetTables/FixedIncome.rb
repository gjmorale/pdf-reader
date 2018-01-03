class SIGA::FixedIncome < SIGA::AssetTable
	def load
		@name = "cartera renta fija"
		@title = Field.new("Detalle Cartera Renta Fija")
		@table_end = Field.new("Valor Total de la Cartera (CLP):")
		@headers = []
			headers << HeaderField.new("Instrumento / Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad (expresada en la moneda de emisión)", headers.size, Setup::Type::FLOAT)
			headers << HeaderField.new(["Precio","Compra"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["T.I.R.","Compra"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Precio","Cierre"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["T.I.R.","Cierre"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valor de","Mercado CLP"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Cupones","Pagados CLP"], headers.size, Setup::Type::INTEGER, true, 4)
		@total = SingleField.new("Valor Total de la Cartera (CLP):",
			[Setup::Type::INTEGER])
		@page_end = 		Field.new("Este estado de cuenta se considerará aprobado si")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		6
		@total_index = 		0
	end


	def each_result_do results, row = nil
		lines = results[0].strings.select{|s| s and not s.empty?}.map do |s|
			s.sub("Tipo: ",'')
			.sub("Reajuste: ",'')
			.sub("Plazo: ",'')
			.sub("Tasa de Emisión: ",'')
			.sub("Emisión: ",'')
			.sub("Vencimiento: ",'')
			.sub(" (años/meses)",'')
			.gsub(/Cupones: .+/,'')
		end
		results[0] = lines.join(' ')
	end
end