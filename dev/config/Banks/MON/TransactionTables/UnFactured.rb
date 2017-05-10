class MON::UnFactured < MON::TransactionTable
	def load
		@name = "movimientos no facturados"
		@title = Field.new("MOVIMIENTOS SIN FACTURAS")
		@table_end = [Field.new("MOVIMIENTOS DE CUSTODIA"), Field.new("No se registran transacciones para el período")]
		@headers = []
			headers << HeaderField.new("Operación", headers.size, Custom::OP_ID, true)
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Factura", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Nemotécnico", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Tipo", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Mercado", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Precio", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Monto", headers.size, Setup::Type::AMOUNT) 
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@mov_map = {
			fecha_movimiento: 	1,
			fecha_pago: 		1,
			concepto: 			4,
			id_ti_valor1: 		5,
			cantidad1: 			6,
			id_ti_valor2: 		3,
			precio: 			7,
			cantidad2: 			8,
			detalle: 			0,
			delta: [
			]
		}
	end
end