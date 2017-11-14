class SAN::TransactionsUSD < SAN::TransactionTable
	def load
		#@verbose = true
		@name = "transactions usd"
		@title = Field.new("Número de cuenta¶¶¶¶¶¶¶¶¶¶ - USD")
		@title_limit = 10
		#@offset = Field.new("Número de cuenta")
		@table_end = Field.new("Saldo final")
		@headers = []
			headers << HeaderField.new("Fecha valor", headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new(["Fecha", "apunte"], headers.size, Setup::Type::LABEL, false, 6)
			headers << HeaderField.new("Créditos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Débitos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("Página¶¶¶¶de¶")
		@total = SingleField.new("Saldo final",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		#@require_offset = 	true
		@require_rows = 	true
		@alt_currency = 'usd'
		@mov_map = {
			fecha_movimiento: 0,
			fecha_pago: 			2,
			concepto: 				1,
			id_ti_valor1: 		1, 
			cantidad1: 				1,
			id_ti_valor2: 		1, # $USD
			precio: 					1,
			cantidad2: 				3,
			detalle: 					1,
			delta: []
		}
	end
end

class SAN::TransactionsEUR < SAN::TransactionTable
	def load
		#@verbose = true
		@name = "transactions eur"
		@title = Field.new("Número de cuenta¶¶¶¶¶¶¶¶¶¶ - EUR")
		@title_limit = 1
		#@offset = Field.new("Número de cuenta")
		@table_end = Field.new("Saldo final")
		@headers = []
			headers << HeaderField.new("Fecha valor", headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new(["Fecha", "apunte"], headers.size, Setup::Type::LABEL, false, 6)
			headers << HeaderField.new("Créditos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Débitos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("Página¶¶¶¶de¶")
		@total = SingleField.new("Saldo final",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		#@require_offset = 	true
		@alt_currency = 'eur'
		@require_rows = 	true
		@mov_map = {
			fecha_movimiento: 0,
			fecha_pago: 			2,
			concepto: 				1,
			id_ti_valor1: 		1, 
			cantidad1: 				1,
			id_ti_valor2: 		1, # $USD
			precio: 					1,
			cantidad2: 				3,
			detalle: 					1,
			delta: []
		}
	end
end

class SAN::TransactionsJPY < SAN::TransactionTable
	def load
		#@verbose = true
		@name = "transactions jpy"
		@title = Field.new("Número de cuenta¶¶¶¶¶¶¶¶¶¶ - JPY")
		@title_limit = 1
		#@offset = Field.new("Número de cuenta")
		@table_end = Field.new("Saldo final")
		@headers = []
			headers << HeaderField.new("Fecha valor", headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Detalle", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new(["Fecha", "apunte"], headers.size, Setup::Type::LABEL, false, 6)
			headers << HeaderField.new("Créditos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Débitos", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("Página¶¶¶¶de¶")
		@total = SingleField.new("Saldo final",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		#@require_offset = 	true
		@require_rows = 	true
		@alt_currency = 'jpy'
		@mov_map = {
			fecha_movimiento: 0,
			fecha_pago: 			2,
			concepto: 				1,
			id_ti_valor1: 		1, 
			cantidad1: 				1,
			id_ti_valor2: 		1, # $USD
			precio: 					1,
			cantidad2: 				3,
			detalle: 					1,
			delta: []
		}
	end
end



