class PER::ESP::CashTransactions < PER::CashTransactionTable
	def load
		@name = "cash transactions"
		@title = Field.new("Detalles del Fondo de Money Market")
		@table_end = Field.new("Saldo al Cierre")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Tipo de Actividad", headers.size, Custom::ACTIVIDAD)
			headers << HeaderField.new("Descripción", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Monto", headers.size, Custom::NUM2, true)
			headers << HeaderField.new("Saldo", headers.size, Custom::NUM2)
		@page_end = 		Field.new("Página ¶¶ de ")
		@total = SingleField.new("Total de Todos los Fondos de Money Market",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			1,
			abono: 				3,
			detalle: 			2
		}
	end

	def pre_check_do new_positions = nil
		initial_amount = new_positions.select{|p| p.detalle.match /^\[/}.first
		new_positions.delete initial_amount
		return initial_amount.value
	end

	def new_movement args
		args = args.map{|arg| "#{arg}".strip}
		abono = @mov_map[:abono].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:abono]], spanish)
		hash = {
			fecha_movimiento: args[@mov_map[:fecha_movimiento]],
			fecha_pago: args[@mov_map[:fecha_pago]],
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: "MONEY MARKET", #CLP
			cantidad1: abono,
			id_ti_valor2: @cash_curr, #CLP
			id_ti2: "Currency", #CLP
			cantidad2: abono,
			detalle: args[@mov_map[:detalle]]
		}
		params = parse_movement hash
		return Movement.new(params) if params
	end


	def parse_movement hash
		hash[:value] = hash[:cantidad1]
		case hash[:concepto]
		when /Retiro/i
			hash[:concepto] = 9005
		when /Dep.sito/i
			hash[:concepto] = 9004
		else
			hash[:concepto] = 9000
		end
		hash
	end
end
