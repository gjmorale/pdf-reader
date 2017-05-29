class TransactionTable < AssetTable

	def get_results
		movements = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				movement = new_movement(results)
				movements << movement if movement
			end
		end
		if present
			return movements
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def new_movement args
		args = args.map{|arg| "#{arg}".strip}
		delta = 0.0
		@mov_map[:delta].each do |d|
			delta += BankUtils.to_number(args[d], spanish)
		end
		hash = {
			fecha_movimiento: args[@mov_map[:fecha_movimiento]],
			fecha_pago: args[@mov_map[:fecha_pago]],
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: args[@mov_map[:id_ti_valor1]], #CLP
			cantidad1: BankUtils.to_number(args[@mov_map[:cantidad1]], spanish),
			id_ti_valor2: args[@mov_map[:id_ti_valor2]],
			precio: BankUtils.to_number(args[@mov_map[:precio]], spanish),
			cantidad2: BankUtils.to_number(args[@mov_map[:cantidad2]], spanish),
			detalle: args[@mov_map[:detalle]],
			delta: delta
		}
		return Movement.new(parse_movement hash)
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
		hash
	end
end

class CashTransactionTable < TransactionTable

	def new_movement args
		args = args.map{|arg| "#{arg}".strip}
		abono = @mov_map[:abono].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:abono]], spanish)
		cargo = @mov_map[:cargo].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:cargo]], spanish)
		hash = {
			fecha_movimiento: args[@mov_map[:fecha_movimiento]],
			fecha_pago: args[@mov_map[:fecha_pago]],
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: @cash_curr, #CLP
			cantidad1: abono - cargo,
			detalle: args[@mov_map[:detalle]]
		}
		return Movement.new(parse_movement hash)
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad1]
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
		hash
	end
end