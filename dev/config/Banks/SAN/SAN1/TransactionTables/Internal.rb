class SAN1::Internal < SAN1::TransactionTable
	def load
		@name = "transferencias origen interno"
		@title = Field.new("ORIGEN INTERNO")
		@table_end = Field.new("TOTAL ORIGEN INTERNO :")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("Fondo Mutuo", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Serie", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cuenta", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Folio", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Monto", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("En caso de no estar conforme con alguna información")
		@total = SingleField.new("TOTAL ORIGEN INTERNO :",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 				0,
			concepto: 					'9005',
			id_ti_valor1: 			1,
			id_ti1: 						'Nemo',
			cantidad1: 					'',
			id_ti_valor2: 			'CLP', 
			id_ti2: 						'Currency', 
			cantidad2: 					5,
			precio: 						'',
			detalle: 						2
		}
	end
end

class SAN1::External < SAN1::TransactionTable
	def load
		@name = "transferencias destino interno"
		@title = Field.new("DESTINO INTERNO")
		@table_end = Field.new("TOTAL DESTINO INTERNO :")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("Fondo Mutuo", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Serie", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cuenta", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Folio", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Monto", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("En caso de no estar conforme con alguna información")
		@total = SingleField.new("TOTAL DESTINO INTERNO :",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 				0,
			concepto: 					'9004',
			id_ti_valor1: 			1,
			id_ti1: 						'Nemo',
			cantidad1: 					'',
			id_ti_valor2: 			'CLP', 
			id_ti2: 						'Currency', 
			cantidad2: 					5,
			precio: 						'',
			detalle: 						2
		}
	end
end

class SAN1::Dividends < SAN1::TransactionTable
	def load
		@name = "dividendos"
		@title = Field.new("REPARTO DIVIDENDOS")
		@table_end = Field.new("TOTAL REPARTO DIVIDENDOS")
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("Fondo Mutuo", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Serie", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cuenta", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Monto Cuotas", headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Valor Cuota del día", headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Monto", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("En caso de no estar conforme con alguna información")
		@total = SingleField.new("TOTAL REPARTO DIVIDENDOS",
			[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
		@total_index = 		0
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 				0,
			concepto: 					'9006',
			id_ti_valor1: 			1,
			id_ti1: 						'Nemo',
			cantidad1: 					4,
			id_ti_valor2: 			'CLP', 
			id_ti2: 						'Currency', 
			cantidad2: 					'0',
			precio: 						5,
			detalle: 						2,
			value: 							6
		}
	end
end