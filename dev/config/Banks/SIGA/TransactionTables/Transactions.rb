class SIGA::Transactions < SIGA::TransactionTable
	def load
		@name = "movimientos de titulos"
		@title = Field.new("Movimientos de Títulos")
		@iterative_title = true
		@table_end = [Field.new("Nota: Para compras y ventas de acciones, P/B señala si cuando éstas fueron realizadas,")]
		@headers = []
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE, true) 				# 0
			headers << HeaderField.new("N°Cmbte", headers.size, Custom::CMBTE) 						# 1
			headers << HeaderField.new("TC", headers.size, Custom::TC) 								# 2
			headers << HeaderField.new("Operación", headers.size, Custom::OP_LABEL) 				# 3
			headers << HeaderField.new("Instrumento", headers.size, Custom::INST_CODE) 				# 4
			headers << HeaderField.new("Emisor", headers.size, Setup::Type::DATE) 					# 5
			headers << HeaderField.new("TR", headers.size, Setup::Type::CURRENCY)					# 6
			headers << HeaderField.new("P/B", headers.size, Custom::PB) 							# 7
			headers << HeaderField.new("Mon.", headers.size, Setup::Type::CURRENCY) 				# 8
			headers << HeaderField.new("Paridad", headers.size, Custom::LONG_ZERO) 					# 9
			headers << HeaderField.new("Cantidad", headers.size, Custom::FLOAT_4) 					# 10
			headers << HeaderField.new("Precio, TIR", headers.size, Setup::Type::AMOUNT) 			# 11
			headers << HeaderField.new("Monto Neto", headers.size, Setup::Type::INTEGER) 			# 12
		@page_end = Field.new("Este estado de cuenta se considerará aprobado si")
		@mov_map = {
			fecha_movimiento: 	0,
			fecha_pago: 		0,
			concepto: 			3,
			id_ti_valor1: 		4,
			id_ti1:				"Nemo",
			cantidad1: 			10,
			id_ti_valor2_default:	"CLP",
			id_ti2:				"Currency",
			precio: 			11,
			cantidad2: 			12,
			detalle: 			3,
			factura: 			1,
			delta: [
			]
		}
	end

	def new_movement args
		quantity = args[@mov_map[:cantidad1]]
		quantity &&= quantity.gsub(/,/,'').gsub(/\./,',')
		args[@mov_map[:cantidad1]] = quantity
		super args
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad2]
		case hash[:concepto]
		when /Vencimiento RF/i
			hash[:concepto] = 9008
		when /Compra R./i
			hash[:concepto] = 9004
		when /(Venta R.|Retiro RF Por Sorteo Letras)/i
			hash[:concepto] = 9005
		else
			hash[:concepto] = 9000
		end
		hash
	end
end