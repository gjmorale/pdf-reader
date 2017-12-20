class SIGA::IIF < SIGA::AssetTable
	def load
		@name = "cartera pagarés"
		@title = Field.new("Detalle Cartera Detalle Cartera Depósitos (IIF)")
		@iterative_title = true
		@headers = []
			headers << HeaderField.new("Instrumento / Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad (número de depósitos)", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new(["Fecha","Venc."], headers.size, Setup::Type::DATE, true, 4)
			headers << HeaderField.new(["Valor de","Rescate"], headers.size, Custom::FLOAT_4, false, 4)
			headers << HeaderField.new(["Moneda","Reajuste"], headers.size, Setup::Type::CURRENCY, false, 4)
			headers << HeaderField.new(["Tasa","Compra"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valor Compra","(CLP)"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Valor Actual","(CLP)"], headers.size, Setup::Type::INTEGER, false, 4)
		@total = SingleField.new("Total mercado(CLP):",
			[Setup::Type::INTEGER])
		@page_end = 		Field.new("Este estado de cuenta se considerará aprobado si")
		@price_index = 		5
		@quantity_index = 	6
		@value_index = 		7
		@total_index = 		0
	end

	def each_result_do results, row = nil
		detail = nil
		line = results[0].strings.select{|s| s and not s.empty?}.first.gsub(/\([A-Z]+\)/,'')
		date = "#{results[2]}".strip
		results[0] = "#{line} #{date}"
	end
end