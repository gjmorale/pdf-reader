class PER::ENG::Dividends < PER::TransactionTable
	def load
		@name = "transactions (dividends)"
		@offset = Field.new("Dividends and Interest")
		@table_end = Field.new("Total Dividends and Interest")
		@headers = []
			headers << HeaderField.new(["Process/","Settlement","Date"], headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Activity Type", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3)
			headers << HeaderField.new("Price", headers.size, Custom::NUM4)
			headers << HeaderField.new("Accrued Interest", headers.size, Custom::NUM2)
			headers << HeaderField.new("Amount", headers.size, Custom::NUM2)
			headers << HeaderField.new("Currency", headers.size, Setup::Type::CURRENCY)
		@page_end = 		Field.new("Page ¶¶ of ")
		@total = SingleField.new("Total Dividends and Interest",
			[Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::CURRENCY], 3, Setup::Align::LEFT)
		@total_index = 		1
		@require_offset = 	true
		@require_rows = 	true
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			1,
			id_ti_valor1: 		4, #TickerBB??
			cantidad1: 			3,
			id_ti_valor2: 		7,
			precio: 			4,
			cantidad2: 			6,
			detalle: 			2,
			delta: [
				5
			]
		}
	end
end

class PER::ENG::Taxes < PER::TransactionTable
	def load
		@name = "transactions (taxes)"
		@offset = Field.new("Taxes Withheld")
		@table_end = Field.new("Total Taxes Withheld")
		@headers = []
			headers << HeaderField.new(["Process/","Settlement","Date"], headers.size, Setup::Type::DATE, true, 6)
			headers << HeaderField.new("Activity Type", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Quantity", headers.size, Custom::NUM3)
			headers << HeaderField.new("Price", headers.size, Custom::NUM4)
			headers << HeaderField.new("Accrued Interest", headers.size, Custom::NUM2)
			headers << HeaderField.new("Amount", headers.size, Custom::NUM2)
			headers << HeaderField.new("Currency", headers.size, Setup::Type::CURRENCY)
		@page_end = 		Field.new("Page ¶¶ of ")
		@total = SingleField.new("Total Taxes Withheld",
			[Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::CURRENCY], 3, Setup::Align::LEFT)
		@total_index = 		1
		@require_offset = 	true
		@require_rows = 	true
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			1,
			id_ti_valor1: 		4, #TickerBB??
			cantidad1: 			3,
			id_ti_valor2: 		7,
			precio: 			4,
			cantidad2: 			6,
			detalle: 			2,
			delta: [
				5
			]
		}
	end
end



