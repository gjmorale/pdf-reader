class PER::ESP::ETFS < PER::AssetTable
	def load
		@name = "etfs"
		@offset = Field.new("PRODUCTOS NEGOCIADOS EN BOLSA")
		@table_end = Field.new("TOTAL DE¶PRODUCTOS NEGOCIADOS EN BOLSA")
		@headers = []
			headers << HeaderField.new("Fecha de Adquisición", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Cantidad", headers.size, Custom::NUM3, true)
			headers << HeaderField.new("Costo por Unidad", headers.size, Custom::NUM4)
			headers << HeaderField.new("Base de Costo", headers.size, Custom::NUM2)
			headers << HeaderField.new("Precio de Mercado", headers.size, Custom::NUM4)
			headers << HeaderField.new("Valor de Mercado", headers.size, Custom::NUM2)
			headers << HeaderField.new(["Ganancia o Pérdida","No Realizada"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Ingresos","Anuales Estimados"], headers.size, Custom::NUM2, false, 4)
			headers << HeaderField.new(["Rédito","Estimado"], headers.size, Setup::Type::PERCENTAGE, false, 4)
		@total = SingleField.new("TOTAL DE¶PRODUCTOS NEGOCIADOS EN BOLSA",
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
		str.split(';').reverse
	end

	def filter_text options
		#puts options.join(';').red
		text = options.select{|o| 
			not o.empty? and
			o =~ /.*[A-Z]{2}.*/ and
			not (o =~ /(Total|CUSIP|ISIN|Opción|Efectivo|^\s*$)/)
		}.each{|o| o.strip!}.join(';')
		code = text.match /(?<=ulos: )[A-Z0-9]+/
		text = text.gsub(/;\s?Código[^;]+($|;)/,' ')
		text << ";#{code}" if code
		#puts text
		text
	end
end


