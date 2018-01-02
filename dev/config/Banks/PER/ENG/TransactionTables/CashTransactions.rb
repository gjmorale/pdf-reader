class PER::ENG::CashTransactions < PER::CashTransactionTable
	def load
		@name = "cash transactions"
		@title = Field.new("Money Market Fund Detail")
		@table_end = Field.new("Closing Balance")
		@headers = []
			headers << HeaderField.new("Date", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Activity Type", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Description", headers.size, Custom::LABEL_OR_BLANK)
			headers << HeaderField.new("Amount", headers.size, Custom::NUM2, true)
			headers << HeaderField.new("Balance", headers.size, Custom::NUM2)
		@page_end = 		Field.new("Page ¶¶ of ")
		@total = SingleField.new("Total All Money Market Funds",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		@title_limit = 		6
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			1,
			abono: 				3,
			detalle: 			2
		}
	end

	def pre_check_do new_positions = nil
		puts new_positions.map{|p| "#{p.detalle}"}
		initial_amount = new_positions.select{|p| p.detalle.match /^\[.+\]/}.first
		new_positions.delete initial_amount
		return initial_amount.value
	end
end
