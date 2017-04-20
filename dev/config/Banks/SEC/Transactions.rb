class SEC::Transactions < SECTransactionTable
	def load
		@name = "transacciones"
		@title = Field.new("INFORME DE TRANSACCIONES")
		@table_end = Field.new("MOVIMIENTOS DE CAJA")
		@headers = []
			headers << HeaderField.new(["FECHA","OPERACIÓN"], headers.size, Setup::Type::DATE, true, 4)#fecha_mov
			headers << HeaderField.new(["FECHA","LIQUIDACIÓN"], headers.size, Setup::Type::DATE, false, 4)#fecha_pago o _mov
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["TIPO","MOVTO"], headers.size, Setup::Type::LABEL, false, 4)#concepto
			headers << HeaderField.new(["NRO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4) #id_sec_1
			headers << HeaderField.new(["NUMERO","OPERACIÓN"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["NÚMERO","FACTURA"], headers.size, Setup::Type::INTEGER, false, 4) #factura
			headers << HeaderField.new("INSTRUMENTO", headers.size, Setup::Type::LABEL, false) #id_ti_valor1
			headers << HeaderField.new(["CANTIDAD/","CUOTAS"], headers.size, Setup::Type::AMOUNT, false, 4) #cantidad1
			headers << HeaderField.new("MDA.", headers.size, Setup::Type::CURRENCY, false)#id_ti_valor2
			headers << HeaderField.new(["PRECIO/","VALOR CUOTA"], headers.size, Setup::Type::AMOUNT, false, 4) #Precio
			headers << HeaderField.new("MONTO", headers.size, Setup::Type::AMOUNT, false) #cantidad2
			headers << HeaderField.new("COMISIÓN", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("DERECHO", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("GASTOS", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("IVA", headers.size, Setup::Type::AMOUNT, false)
			#puts headers
		@page_end = 		Field.new("Página ")
	end

	def new_movement *args
		delta = 0
		args = args[0]
		args[12..-1].map{|arg| delta += BankUtils.to_number(arg, spanish)}
		hash = {
			fecha_movimiento: args[0],
			fecha_pago: args[1],
			concepto: args[3],
			id_sec1: args[4],
			factura: args[6],
			id_ti_valor1: args[7],
			cantidad1: BankUtils.to_number(args[8], spanish),
			id_ti_valor2: args[9],
			precio: BankUtils.to_number(args[10], spanish),
			cantidad2: BankUtils.to_number(args[11], spanish),
			delta: delta
		}
		Movement.new(hash)
	end
end

class SEC::TransactionsAlt < SECTransactionTable
	def load
		@name = "transacciones en formato alternativo"
		@title = Field.new("INFORME DE TRANSACCIONES")
		@table_end = Field.new("Página ¶¶ de ¶¶")
		@headers = []
			headers << HeaderField.new(["FECHA"], headers.size, Setup::Type::DATE, true, 4)#fecha_mov
			headers << HeaderField.new("[GESTIONADO|MANDATO]", headers.size, Custom::GEST, false)
			headers << HeaderField.new(["TIPO","MOVIMIENTO"], headers.size, Setup::Type::LABEL, false, 4)#concepto
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4) #id_sec_1
			headers << HeaderField.new(["NUMERO","[OPERACIÓN|DOCUMENTO]"], headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new("INSTRUMENTO", headers.size, Setup::Type::LABEL, false) #id_ti_valor1
			headers << HeaderField.new(["CANTIDAD/","CUOTAS"], headers.size, Setup::Type::AMOUNT, false, 4) #cantidad1
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY, false)#id_ti_valor2
			headers << HeaderField.new(["PRECIO/","VALOR CUOTA"], headers.size, Setup::Type::AMOUNT, false, 4) #Precio
			headers << HeaderField.new("MONTO", headers.size, Setup::Type::AMOUNT, false) #cantidad2
			#puts headers
		@page_end = 		Field.new("Página ")
	end

	def new_movement *args
		args = args[0]
		hash = {
			fecha_movimiento: args[0],
			fecha_pago: args[0],
			concepto: args[2],
			id_sec1: args[3],
			factura: "",
			id_ti_valor1: args[5],
			cantidad1: BankUtils.to_number(args[6], spanish),
			id_ti_valor2: args[7],
			precio: BankUtils.to_number(args[8], spanish),
			cantidad2: BankUtils.to_number(args[9], spanish),
			delta: 0
		}
		Movement.new(hash)
	end
end