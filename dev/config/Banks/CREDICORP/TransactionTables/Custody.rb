class CrediCorp::Custody < CrediCorp::TransactionTable
	def load
		@name = "movimientos en custodia"
		@offset = Field.new("EN CUSTODIA")
		@headers = []
			headers << HeaderField.new("TRANSACCIÓN", headers.size, Setup::Type::DATE, true)
			headers << HeaderField.new("LIQUIDACIÓN", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("#CMBTE", headers.size, Custom::MOV_ID)
			headers << HeaderField.new("TC", headers.size, Setup::Type::BLANK)
			headers << HeaderField.new("OPERACIÓN", headers.size, Custom::OPERATION)
			headers << HeaderField.new("INSTRUMENTO", headers.size, Custom::ASSET_LABEL)
			headers << HeaderField.new("EMISOR", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("TR", headers.size, Setup::Type::BLANK)
			headers << HeaderField.new("P/B", headers.size, Setup::Type::BLANK)
			headers << HeaderField.new("MONEDA", headers.size, Setup::Type::CURRENCY)
			headers << HeaderField.new("CANTIDAD", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("PRECIO.TIR", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("MONTO NETO", headers.size, Setup::Type::AMOUNT)
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		1,
			concepto: 			4,
			id_ti_valor1: 		5,
			cantidad1: 			10,
			id_ti_valor2: 		3,
			precio: 			11,
			cantidad2: 			12,
			detalle: 			2,
			delta: [
			]
		}
	end
end

			