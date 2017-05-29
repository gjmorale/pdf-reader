class PER::ENG::Bonds < PER::AssetTable
	def load
		@name = "corporative bonds"
		@offset = Field.new("Bonos Corporativos")
		@table_end = Field.new("Total de Bonos Corporativos")
		@headers = []
			headers << HeaderField.new("Fecha de Adquisición", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Cantidad", headers.size, Custom::NUM3, true)
			headers << HeaderField.new("Costo por Unidad", headers.size, Custom::NUM4)
			headers << HeaderField.new(["Base de Costo","Ajustada"], headers.size, Custom::NUM2)
			headers << HeaderField.new("Precio de Mercado", headers.size, Custom::NUM4)
			headers << HeaderField.new("Valor de Mercado", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Ganancia o Pérdida","No Realizada"], headers.size, Custom::NUM2, false, 5)
			headers << HeaderField.new(["Intereses","Devengados"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Ingresos Anuales","Estimados"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Rédito","Estimado"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@skips = ['Base de Costo Original: \$[0-9,.\s]+']
		@total = SingleField.new("Total de Bonos Corporativos",
			BankUtils.to_arr(Setup::Type::AMOUNT,4))
		@page_end = 		Field.new("Página ¶¶ de ")
		@price_index = 		4
		@quantity_index = 	1
		@value_index = 		5
		@total_index = 		1
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		2
		@total_column = 	0
	end

	def parse_position str, type
		if str =~ /ISIN [A-Z0-9]{12}/
			str.split(';').reverse
		else
			[str,nil]
		end
	end
end
