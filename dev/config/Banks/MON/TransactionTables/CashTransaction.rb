class MON::CashTransaction < MON::CashTransactionTable
	def load
		@name = "movimientos de caja"
		@title = Field.new("INFORME DE CAJA-MONEDA : PESO")
		@table_end = [Field.new("SALDO FINAL"), Field.new("No se registran transacciones para el período")]
		@headers = []
			headers << HeaderField.new("Folio", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Factura", headers.size, Setup::Type::BLANK)
			headers << HeaderField.new("Movimiento", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Ingreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Egreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@total = SingleField.new("SALDO FINAL",
			[Setup::Type::INTEGER], 3, Setup::Align::LEFT)
		@total_index = 		0
		@cash_curr = "CLP"
		@mov_map = {
			fecha_movimiento: 	1,
			fecha_pago: 		1,
			concepto: 			3,
			abono: 				4,
			cargo: 				5,
			detalle: 			3
		}
	end

	def each_result_do results, row = nil
		if results[3] =~ /SALDO INICIAL/i
			results[4] = results[6]
		end
		results[5] = results[5].gsub('-','')
	end

	def pre_check_do new_positions
		initial_amount = new_positions.select{|p| p.detalle =~ /SALDO INICIAL/i}
		if initial_amount and initial_amount.any?
			initial_amount = initial_amount.first
		end
		return new_positions
	end

	def post_check_do new_positions
		initial_amount = new_positions.select{|p| p.detalle =~ /SALDO INICIAL/i}
		if initial_amount and initial_amount.any?
			initial_amount = initial_amount.first
			new_positions.delete initial_amount 
		end
		return new_positions
	end
end