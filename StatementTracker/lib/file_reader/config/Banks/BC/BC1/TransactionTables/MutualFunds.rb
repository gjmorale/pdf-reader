class BC1::MutualFundsMovCLP < BC1::TransactionTable
	def load
		@name = "movimientos de fondos de inversion en clp"
		@title = Field.new("Fondos Mutuos en Pesos Chilenos: Movimientos del Período")
		@table_end = Field.new("Página ")
		@headers = []
			headers << HeaderField.new("Fecha",headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("Fondo Mutuo",headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Serie",headers.size, Custom::BLANK, false)
			headers << HeaderField.new("Características",headers.size, Custom::BLANK, false)
			headers << HeaderField.new("Cuenta",headers.size, Custom::FIN_RUT, false)
			headers << HeaderField.new("Tipo Operación",headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Nº Cuotas", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Valor Cuota ($)", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Monto","Operación ($)"], headers.size, Setup::Type::AMOUNT, false, 4)
		@page_end = 		Field.new("Página ")
		@title_limit = 		1
	end

	def new_movement *args
		args = args[0].map{|arg| arg.inspect.strip}
		hash = {
			fecha_movimiento: args[0],
			fecha_pago: args[0],
			concepto: args[5],
			id_sec1: args[2],
			id_ti_valor1: args[1], #CLP
			cantidad1: BankUtils.to_number(args[6], spanish),
			id_ti_valor2: "CLP",
			precio: BankUtils.to_number(args[7], spanish),
			cantidad2: BankUtils.to_number(args[8], spanish),
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
		when "Compra", "Suscripción"
			hash[:concepto] = 9004
		when "Apo.Pago Divid."
			hash[:concepto] = 9006
		end
		hash
	end
end