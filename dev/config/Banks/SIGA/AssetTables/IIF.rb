class SIGA::IIF < SIGA::AssetTable
	def load
		@name = "cartera pagarés"
		@title = Field.new("Detalle Cartera Renta Variable")
		@offset = Field.new("Mercado: CFI CLP")
		@require_offset = false
		@table_end = Field.new("Total mercado(CLP):")
		@headers = []
			headers << HeaderField.new("Instrumento / Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Precio", headers.size, Custom::FLOAT_3)
			headers << HeaderField.new("Valor de Mercado", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new(["Dividendos"," Recibidos"], headers.size, Custom::NON_ZERO, true, 4)
		@total = SingleField.new("Total mercado(CLP):",
			[Setup::Type::INTEGER])
		@page_end = 		Field.new("Este estado de cuenta se considerará aprobado si")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		3
		@total_index = 		0
	end

	def each_result_do results, row = nil
		detail = nil
		lines = results[0].strings.select{|s| s and not s.empty?}.map do |s|
			d = s[/(?<=Rubro:).*$/]
			detail ||= d
			!!d ? '' : s
		end
		results[0] = lines[0]
		results[0] << ";#{lines[-1]}"
		results[0] << " - #{detail}" if detail and not detail.empty?
	end

	def parse_position str, type
		parts = str.split(';')
		if parts.size > 1
			[parts[0..-2].join(), parts.last]
		else
			[str,nil]
		end
	end
end