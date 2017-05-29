class PER::ENG::CashTransactions < PER::CashTransactionTable
	def load
		@name = "cash transactions"
		@title = Field.new("Detalles del Fondo de Money Market")
		@table_end = Field.new("Saldo al Cierre")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Tipo de Actividad", headers.size, Setup::Type::LABEL)
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
end
