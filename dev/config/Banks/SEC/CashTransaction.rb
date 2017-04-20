class SEC::CashTransactions < SECTransactionTable
	def load
		@name = "transacciones de caja en clp"
		@title = Field.new("CAJA: PESOS")
		@table_end = Field.new("CAJA: ")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE, true, 4)
			headers << HeaderField.new("MANDATO" , headers.size, Custom::GEST, false, 4)
			headers << HeaderField.new(["NUMERO","CUENTA"], headers.size, Custom::N_CUENTA, false, 4)
			headers << HeaderField.new("OPERACIÓN", headers.size, Custom::OP_CODE, false)
			headers << HeaderField.new("DOCUMENTO", headers.size, Setup::Type::INTEGER, false) 
			headers << HeaderField.new("DESCRIPCIÓN", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("CARGO", headers.size, Setup::Type::AMOUNT, false) 
			headers << HeaderField.new("ABONO", headers.size, Setup::Type::AMOUNT, false) 
			headers << HeaderField.new("SALDO", headers.size, Setup::Type::AMOUNT, false) 
			#puts headers
		@page_end = 		Field.new("Página ")
	end

	def new_movement *args
		args = args[0]
		return nil unless args[3] =~ /^(AC|DA)$/
		cargo = BankUtils.to_number(args[6], spanish)
		abono = BankUtils.to_number(args[7], spanish)
		neto = abono - cargo
		hash = {
			fecha_movimiento: args[0],
			fecha_pago: args[0],
			id_sec1: args[2],
			id_ti_valor1: "CLP", #CLP
			cantidad1: neto, 	# abono o cargo	valor absoluto	# O 1.0?
			detalle: args[5],
		}
		return CashMovement.new(hash)
	end
end










