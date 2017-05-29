class PER::ENG::Transactions < PER::TransactionTable
	def load
		@name = "transactions"
		@title = Field.new("Transacciones¶Ordenadas por Fecha")
		@table_end = Field.new("Valor Total de las Transacciones")
		@headers = []
			headers << HeaderField.new(["Fecha de","Proces.","o Liquid."], headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new(["Fecha de","Operación o","Transac."], headers.size, Setup::Type::DATE, false, 6)
			headers << HeaderField.new("Tipo de Actividad", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Descripción", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad", headers.size, Custom::NUM3)
			headers << HeaderField.new("Precio", headers.size, Custom::NUM4)
			headers << HeaderField.new(["Intereses","Devengados"], headers.size, Setup::Type::BLANK, false, 4)
			headers << HeaderField.new("Importe", headers.size, Custom::NUM2)
			headers << HeaderField.new("Divisa", headers.size, Setup::Type::CURRENCY)
		@page_end = 		Field.new("Página ¶¶ de ")
		@total = SingleField.new("Valor Total de las Transacciones",
			[Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::CURRENCY], 3, Setup::Align::LEFT)
		@total_index = 		1
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		1,
			concepto: 			2,
			id_ti_valor1: 		5, #TickerBB??
			cantidad1: 			4,
			id_ti_valor2: 		8,
			precio: 			5,
			cantidad2: 			7,
			detalle: 			3,
			delta: [
			]
		}
	end
end

class PER::ENG::TransactionsAlt < PER::TransactionTable
	def load
		@name = "transacciones alternativas"
		@title = Field.new("Transacciones¶Ordenadas por Fecha")
		@table_end = Field.new("Valor Total de las Transacciones")
		@headers = []
			headers << HeaderField.new(["Fecha de","Proces.","o Liquid."], headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Tipo de Actividad", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Descripción", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad", headers.size, Custom::NUM3)
			headers << HeaderField.new("Precio", headers.size, Custom::NUM4)
			headers << HeaderField.new(["Intereses","Devengados"], headers.size, Setup::Type::BLANK, false, 4)
			headers << HeaderField.new("Importe", headers.size, Custom::NUM2)
			headers << HeaderField.new("Divisa", headers.size, Setup::Type::CURRENCY)
		@page_end = 		Field.new("Página ¶¶ de ")
		@total = SingleField.new("Valor Total de las Transacciones",
			[Custom::NUM2,
			Custom::NUM2,
			Setup::Type::CURRENCY], 3, Setup::Align::LEFT)
		@total_index = 		1
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		1,
			concepto: 			2,
			id_ti_valor1: 		5, #TickerBB??
			cantidad1: 			4,
			id_ti_valor2: 		8,
			precio: 			5,
			cantidad2: 			6,
			detalle: 			3,
			delta: [
			]
		}
	end
end



