class SIGA::CashTransaction < SIGA::CashTransactionTable
	def load
		@name = "movimientos de caja"
		@title = Field.new("Movimientos de caja pesos (CLP)")
		@table_end = Field.new("Saldo Final del Periodo")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("#Ref", headers.size, Custom::REF_NUM)
			headers << HeaderField.new("Operacion", headers.size, Custom::MOV_CODE)
			headers << HeaderField.new("Instrumentos", headers.size, Custom::INST_CODE)
			headers << HeaderField.new("Cargo CLP", headers.size, Setup::Type::INTEGER, true)
			headers << HeaderField.new("Abono CLP", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Saldo CLP", headers.size, Setup::Type::INTEGER)
		@page_end = Field.new("Este estado de cuenta se considerará aprobado si")
		@total = SingleField.new("Saldo Final del Periodo",
			[Setup::Type::INTEGER], 3, Setup::Align::LEFT)
		@total_index = 		0
		@cash_curr = "CLP"
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			2,
			abono: 				5,
			cargo: 				4,
			instrument: 		3,
			detalle: 			2,
			factura: 			1
		}
	end
end