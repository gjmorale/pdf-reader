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
			headers << HeaderField.new("Emisor",headers.size,Custom::EMISOR,false)
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
							if @last_stock
								@last_stock.add_value @last_fee if @last_fee
								@last_stock.add_value @last_tax if @last_tax
								@last_stock.detalle << " + #{@last_fee}(Comisión)" if @last_fee
								@last_stock.detalle << " + #{@last_tax}(IVA)" if @last_tax
								@last_stock = @last_fee = @last_tax = nil
							end
							movements << movement
							@last_stock = movement
						when /Comisión/i
							@last_fee = movement.value
						when /IVA/i
							@last_tax = movement.value
						end 
					else
						movements << movement
					end
				end
			end
			if @last_stock
				@last_stock.add_value @last_fee if @last_fee
				@last_stock.add_value @last_tax if @last_tax
				@last_stock.detalle << " + #{@last_fee}(Comisión)" if @last_fee
				@last_stock.detalle << " + #{@last_tax}(IVA)" if @last_tax
			end
		end
		if present
			return movements
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def to_currency arg
		return "" unless arg
		case arg
		when /(DOOBS|DOLAR)/
			"USD"
		when /PESOS?/
			"CLP"
		else
			arg
		end
	end

	def new_movement *args
		args = args[0].map{|arg| "#{arg}".strip}
		if args[2] != Result::NOT_FOUND and args[0] != "00/00/0000"
			if args[1] =~ /Dividendo/i
				hash = {
					fecha_movimiento: args[2],
					fecha_pago: args[0],
					concepto: args[1],
					id_ti_valor1: args[1].gsub(/Dividendo\s?/i, ""), #CLP
					cantidad1: 0,
					id_ti_valor2: to_currency(args[6]),
					precio: BankUtils.to_number(args[8], spanish),
					cantidad2: BankUtils.to_number(args[9], spanish),
					delta: 0,
					detalle: args[1]
				}
			elsif args[4] =~ /(DOOBS|PESO|DOLAR)/
				hash = {
					fecha_movimiento: args[2],
					fecha_pago: args[0],
					concepto: args[1],
					id_ti_valor1: to_currency(args[4]), #CLP
					cantidad1: BankUtils.to_number(args[5], spanish),
					delta: 0,
					detalle: args[1]
				}
			else
				hash = {
					fecha_movimiento: args[2],
					fecha_pago: args[0],
					concepto: args[1],
					id_ti_valor1: to_currency(args[4]), #CLP
					cantidad1: BankUtils.to_number(args[5], spanish),
					id_ti_valor2: to_currency(args[6]),
					precio: BankUtils.to_number(args[8], spanish),
					cantidad2: BankUtils.to_number(args[9], spanish),
					delta: 0,
					detalle: args[1]
				}
			end
			return Movement.new(parse_movement hash)
		else
			return nil
		end
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad2]
		case hash[:concepto]
		when /^(Venta|Rescate)/i
			hash[:concepto] = 9005
		when /^(Aporte Efect)/i
			hash[:concepto] = 9001
		when /^(Compra|Aporte)/i
			hash[:concepto] = 9004
		when /Patrimonio/i
			hash[:concepto] = 9013
		when /Retiro/i
			hash[:concepto] = 9002
		when /^Dividendo/i
			hash[:concepto] = 9006
		when /^Dif\./i
			hash[:concepto] = 9013
		else
			hash[:concepto] = 9000
		end

		case hash[:id_ti_valor2]
		when /CLP/i
			hash[:id_ti2] = "Currency"
		when /USD/i
			hash[:detalle] << " (CLP: #{hash[:cantidad2]})"
			hash[:cantidad2] = (hash[:cantidad1]*hash[:precio]).round(0)
			hash[:id_ti2] = "Currency"
		end

		case hash[:id_ti_valor1]
		when /(CLP|USD)/i
			hash[:id_ti1] = "Currency"
		end
		hash
	end

end
