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

	def parse_movement hash
		puts hash
		hash[:value] = hash[:cantidad1]
		case hash[:concepto]
		when /Factura (Venta|Compra)/i
			hash[:invalid] = true
		when /(Venta)/i
			hash[:concepto] = 9005
		when /(Compra)/i
			hash[:concepto] = 9004
		when /(Aporte)/i
			hash[:concepto] = 9001
			hash[:id_ti_valor1] = @cash_curr
			hash[:id_ti1] = "Currency"
		when /(Rescate)/i
			hash[:concepto] = 9002
			hash[:id_ti_valor1] = @cash_curr
			hash[:id_ti1] = "Currency"
		when /Patrimonio/i
			hash[:concepto] = 9013
		when /Retiro/i
			hash[:concepto] = 9002
		when /Dividendo/i
			hash[:concepto] = 9006
			hash[:cantidad2] = hash[:cantidad1]
			hash[:cantidad1] = 0
			hash[:id_ti_valor2] = @cash_curr
			hash[:id_ti2] = "Currency"
			hash[:id_ti_valor1] = "#{hash[:detalle].match /(?<=DIVIDENDO ).+$/i}"
		else
			hash[:concepto] = 9000
		end
		hash
	end
end