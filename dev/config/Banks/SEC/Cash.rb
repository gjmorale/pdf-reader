class SEC::Cash < SECAssetTable
	def load
		@name = "caja"
		@title = Field.new("RESUMEN DE SALDOS EN CAJA")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("CAJA", headers.size, Setup::Type::LABEL, true, 6, Setup::Align::LEFT, 50)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new(["SALDO EN CAJA","SEGUN MONEDA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["SALDO EN CAJA","EN PESOS ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
			#puts headers
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_default =	1.0
		@quantity_index = 	3
		@value_index = 		3
		@total_index = 		0
	end

	def pre_check_do positions
		in_usd = positions.select{|p| p.name =~ /En Dolar/i }
		if in_usd.any?
			in_usd.each do |p|
				p.price = "USD"
			end
			@total = nil
		end
	end
end