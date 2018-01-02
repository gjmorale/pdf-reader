class TransactionTable < AssetTable

	def get_results
		movements = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}		#Row results
				each_result_do results, row	
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
			factura: @mov_map[:factura] ? args[@mov_map[:factura]] : '',
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: args[@mov_map[:id_ti_valor1]], #CLP
			id_ti1: @mov_map[:id_ti1],
			cantidad1: BankUtils.to_number(args[@mov_map[:cantidad1]], spanish),
			id_ti_valor2: @mov_map[:id_ti_valor2] ? args[@mov_map[:id_ti_valor2]] : @mov_map[:id_ti_valor2_default],
			id_ti2: @mov_map[:id_ti2],
			precio: BankUtils.to_number(args[@mov_map[:precio]], spanish),
			cantidad2: BankUtils.to_number(args[@mov_map[:cantidad2]], spanish),
			detalle: args[@mov_map[:detalle]],
			delta: delta
		}
		params = parse_movement hash
		return Movement.new(params) if params
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad2]
		case hash[:id_ti_valor2]
		when /^(CLP|USD)$/i
			hash[:id_ti2] = "Currency"
		end
		case hash[:id_ti_valor1]
		when /^(CLP|USD)$/i
			hash[:id_ti1] = "Currency"
		end
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
			factura: @mov_map[:factura] ? args[@mov_map[:factura]] : '',
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: @cash_curr, #CLP
			cantidad1: abono - cargo,
			detalle: args[@mov_map[:detalle]]
		}
		params = parse_movement hash
		return Movement.new(params) if params
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad1]
		case hash[:id_ti_valor1]
		when /^(CLP|USD)$/i
			hash[:id_ti1] = "Currency"
		end
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