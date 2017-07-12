class BC1::StocksMovCLP < BC1::TransactionTable
	def load
		@name = "movimientos de acciones en clp"
		@title = Field.new("Acciones Nacionales: Movimientos del Período")
		@table_end = Field.new(" del Período:")
		@headers = []
			headers << HeaderField.new("Fecha",headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("Serie",headers.size, Custom::BLANK, false)
			headers << HeaderField.new("Tipo Inst.",headers.size, Custom::INSTRUMENT, false)
			headers << HeaderField.new("Operación",headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Cantidad",headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Precio ($)",headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Monto ($)",headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Factura",headers.size, Custom::FACTURA, false)
			headers << HeaderField.new("Custodia",headers.size, Custom::CUSTODIA, false)
		@total = SingleField.new(" del Período:",
			[Setup::Type::AMOUNT], 
			3, Setup::Align::LEFT)
		@page_end = 		Field.new("Página ")
		@total_index = 		0
		@title_limit = 1
	end

	def new_movement *args
		args = args[0].map{|arg| arg.inspect.strip}
		hash = {
			fecha_movimiento: args[0],
			fecha_pago: args[0],
			concepto: args[3],
			factura: args[7],
			id_ti_valor1: args[1], #CLP
			cantidad1: BankUtils.to_number(args[4], spanish),
			id_ti_valor2: "CLP",
			precio: BankUtils.to_number(args[5], spanish),
			cantidad2: BankUtils.to_number(args[6], spanish),
			delta: 0,
			detalle: args[2]
		}
		return Movement.new(parse_movement hash)
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad2]
		hash[:detalle] << " - #{hash[:concepto]}"
		case hash[:concepto]
		when "Venta"
			hash[:concepto] = 9005
		when "Compra"
			hash[:concepto] = 9004
		end
		hash
	end
end