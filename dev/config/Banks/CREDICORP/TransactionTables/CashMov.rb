class CrediCorp::CashMovCLP < CrediCorp::CashTransactionTable
	def load
		@name = "movimientos de caja clp"
		@offset = Field.new("CAJA CLP")
		@table_end = Field.new("FECHA FINAL PERIODO")
		@headers = []
			headers << HeaderField.new("TRANSACCIÓN", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("LIQUIDACIÓN", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("#REF", headers.size, Custom::MOV_ID, true)
			headers << HeaderField.new("OPERACIÓN", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("INSTRUMENTO", headers.size, Custom::ASSET_LABEL)
			headers << HeaderField.new("CARGO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("ABONO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO", headers.size, Setup::Type::AMOUNT)
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		1,
			concepto: 			3,
			id_ti_valor1: 		4,
			abono: 				6,
			cargo: 				5,
			detalle: 			2
		}
	end
end

class CrediCorp::CashMovUSD < CrediCorp::CashTransactionTable
	def load
		@name = "movimientos de caja usd"
		@offset = Field.new("CAJA USD")
		@table_end = Field.new("FECHA FINAL PERIODO")
		@headers = []
			headers << HeaderField.new("TRANSACCIÓN", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("LIQUIDACIÓN", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("#REF", headers.size, Custom::MOV_ID, true)
			headers << HeaderField.new("OPERACIÓN", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("INSTRUMENTO", headers.size, Custom::ASSET_LABEL)
			headers << HeaderField.new("CARGO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("ABONO", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("SALDO", headers.size, Setup::Type::AMOUNT)
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		1,
			concepto: 			3,
			id_ti_valor1: 		4,
			abono: 				6,
			cargo: 				5,
			detalle: 			2
		}
		@cash_curr = "USD"
	end
end