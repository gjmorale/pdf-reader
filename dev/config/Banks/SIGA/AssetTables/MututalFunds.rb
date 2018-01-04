class SIGA::MutualFunds < SIGA::AssetTable
	def load
		@name = "cartera fondos mutuos"
		@title = Field.new("Detalle Cartera Fondos Mutuos")
		@table_end = Field.new("Valor Total de la Cartera")
		@headers = []
			headers << HeaderField.new("Instrumento / Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad (número de Cuotas)", headers.size, Custom::FLOAT_4)
			headers << HeaderField.new("Valor Cuota", headers.size, Custom::FLOAT_4)
			headers << HeaderField.new(["Valor Actual","(CLP)"], headers.size, Setup::Type::INTEGER, true, 4)
		@total = SingleField.new("Valor Total de la Cartera",
			[Setup::Type::INTEGER])
		@page_end = 		Field.new("Este estado de cuenta se considerará aprobado si")
		@price_index = 		2
		@quantity_index = 	1
		@value_index = 		3
		@total_index = 		0
	end


	def each_result_do results, row = nil
		results[0] = results[0].strings.select{|s| s and not s.empty?}.first
	end
end