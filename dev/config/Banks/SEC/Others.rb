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


class SEC::ETFForeign < SECAssetTable
	def load
		@name = "acciones extranjeras"
		@title = Field.new("ETF")
		@table_end = Field.new("TOTAL")
		@headers = []
			headers << HeaderField.new("INSTRUMENTO", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA)
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY)
			headers << HeaderField.new("CANTIDAD", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["PRECIO","COMPRA"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["MONTO","INVERTIDO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["PRECIO","ACTUAL"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALOR DE","MERCADO"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["UTILIDADES/","PÉRDIDAS"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALORIZACIÓN","EN USD"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["VALORIZACIÓN","EN $"], headers.size, Setup::Type::AMOUNT, false, 4)
		@total = SingleField.new("TOTAL",
			[Setup::Type::AMOUNT, 
			Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@price_index = 		7
		@quantity_index = 4
		@value_index = 		11
		@total_index = 		1
	end
end

