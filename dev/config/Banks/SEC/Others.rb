class SEC::Others < SECAssetTable
	def load
		@name = "fondos pendientes y otros"
		@title = Field.new("SALDO TRANSITORIO AGF")
		@table_end = Field.new("TOTAL EN PESOS")
		@headers = []
			headers << HeaderField.new("FECHA", headers.size, Setup::Type::DATE, true, 4, Setup::Table.header_orientation, 50)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new("ESTADO", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new(["NÚMERO","OPERACIÓN"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new("FONDO", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new(["FECHA","DISPONIBILIDAD"], headers.size, Setup::Type::DATE, false, 4)
			headers << HeaderField.new(["FECHA","PAGO"], headers.size, Setup::Type::DATE, false, 4)
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY, false)
			headers << HeaderField.new("MONTO", headers.size, Setup::Type::AMOUNT, false)
		@total = SingleField.new("TOTAL EN PESOS",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		9
		@quantity_default = 0.0
		@value_index = 		9
		@total_index = 		0
	end

	def each_result_do results, row = nil
		case results[8]
		when /CLP/i
			@alt_currency =	:clp
		when /USD/i
			@alt_currency =	:usd
		when /DO/i
			@alt_currency =	:usd
		else
			@alt_currency = nil
		end
		#puts "#{results}"
	end

	def pre_check_do positions = nil
		@alt_currency = nil
	end
end

