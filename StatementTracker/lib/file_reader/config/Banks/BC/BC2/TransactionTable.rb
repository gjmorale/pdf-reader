class BC2::TransactionTable < BC::TransactionTable
	#Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file }

	def load 
		@name = "transacciones"
		@title = Field.new("CUENTA CORRIENTE ENTRE EL ")
		@table_end = Field.new("Página ")
		@headers = []
			headers << HeaderField.new(["Fecha","Liquidación"],headers.size,Setup::Type::DATE,true, 4)
			headers << HeaderField.new("Movimiento",headers.size,Setup::Type::LABEL,false)
			headers << HeaderField.new(["Fecha","Movimiento"],headers.size,Setup::Type::DATE,false, 4)
			headers << HeaderField.new("Emisor",headers.size,Setup::Type::LABEL,false)
			headers << HeaderField.new("Instrumento",headers.size,Setup::Type::LABEL,false)
			headers << HeaderField.new("Unidades",headers.size,Setup::Type::FLOAT,false)
			headers << HeaderField.new("UM",headers.size,Setup::Type::CURRENCY,false)
			headers << HeaderField.new(["Fecha","Vencimiento"],headers.size,Setup::Type::DATE,false, 4)
			headers << HeaderField.new(["Tir o","Precio"],headers.size,Setup::Type::FLOAT,false, 4)
			headers << HeaderField.new(["Monto","Transado UMS"],headers.size,Setup::Type::FLOAT,false, 4)
			headers << HeaderField.new("Saldo UMS",headers.size,Setup::Type::FLOAT,false)
		@page_end = 		Field.new("Página ")
	end

	def get_results
		movements = []
		@last_stock = @last_iva = @last_comission
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				movement = new_movement(results)
				if movement
					if movement.detalle =~ /Acciones/i
						case movement.detalle
						when /(Venta|Compra)/i
							movements << movement
							@last_stock = movement
						when /Comisión/i
							@last_stock.add_value movement.value
							@last_stock.detalle << " + #{movement.value}(Comisión)"
						when /IVA/i
							@last_stock.add_value movement.value
							@last_stock.detalle << " + #{movement.value}(IVA)"
						end 
					else
						movements << movement
					end
				end
			end
		end
		if present
			return movements
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def new_movement *args
		args = args[0].map{|arg| "#{arg}".strip}
		if args[2] != Result::NOT_FOUND and args[0] != "00/00/0000"
			hash = {
				fecha_movimiento: args[2],
				fecha_pago: args[0],
				concepto: args[1],
				id_ti_valor1: args[4], #CLP
				cantidad1: BankUtils.to_number(args[5], spanish),
				id_ti_valor2: args[6],
				precio: BankUtils.to_number(args[8], spanish),
				cantidad2: BankUtils.to_number(args[9], spanish),
				delta: 0,
				detalle: args[1]
			}
			return Movement.new(parse_movement hash)
		else
			return nil
		end
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad2]
		case hash[:concepto]
		when /(Venta|Rescate)/i
			hash[:concepto] = 9005
		when /(Compra|Aporte)/i
			hash[:concepto] = 9004
		when /Patrimonio/i
			hash[:concepto] = 9013
		when /Retiro/i
			hash[:concepto] = 9002
		else
			hash[:concepto] = 9000
		end

		case hash[:id_ti_valor2]
		when /PESO/i
			hash[:id_ti_valor2] = "CLP"
		when /DOLAR/i
			hash[:detalle] << " (CLP: #{hash[:cantidad2]})"
			hash[:cantidad2] = (hash[:cantidad1]*hash[:precio]).round(0)
			hash[:id_ti_valor2] = "USD"
		when /DOOBS/i
			hash[:detalle] << " (CLP: #{hash[:cantidad2]})"
			hash[:concepto] = 9000
			hash[:cantidad2] = (hash[:cantidad1]*hash[:precio]).round(0)
			hash[:id_ti_valor2] = "DOOBS*"
		end
		hash
	end

end
