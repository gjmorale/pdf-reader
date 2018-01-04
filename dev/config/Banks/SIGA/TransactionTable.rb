class SIGA::TransactionTable < TransactionTable

	def pre_load *args
		super
		@spanish = true
		@label_index = 0
		@title_limit = 0
	end
end

class SIGA::CashTransactionTable < CashTransactionTable

	def pre_load *args
		super
		@spanish = true
		@label_index = 0
		@title_limit = 0
	end

	def new_movement args
		args = args.map{|arg| "#{arg}".strip}
		abono = @mov_map[:abono].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:abono]], spanish)
		cargo = @mov_map[:cargo].nil? ? 0.0 : BankUtils.to_number(args[@mov_map[:cargo]], spanish)
		id_ti_1 = id_ti_2 = id_ti_valor1 = id_ti_valor2 = cantidad1 = cantidad2 = nil
		instrument = args[@mov_map[:instrument]]
		if instrument and not (instrument.empty? or instrument == Result::NOT_FOUND)
			id_ti_valor1 = instrument
			id_ti_1 = "Nemo"
			cantidad1 = 0.0
			id_ti_valor2 = "CLP"
			id_ti_2 = "Currency"
			cantidad2 = (abono - cargo).abs
		else
			id_ti_valor1 = "CLP"
			id_ti_1 = "Currency"
			cantidad1 = (abono - cargo).abs
		end
		hash = {
			fecha_movimiento: args[@mov_map[:fecha_movimiento]],
			fecha_pago: args[@mov_map[:fecha_pago]],
			factura: args[@mov_map[:factura]],
			concepto: args[@mov_map[:concepto]],
			id_ti_valor1: id_ti_valor1, 
			id_ti1: id_ti_1, 
			cantidad1: cantidad1,
			id_ti_valor2: id_ti_valor2, 
			id_ti2: id_ti_2, 
			cantidad2: cantidad2,
			detalle: args[@mov_map[:detalle]],
			value: abono-cargo
		}
		hash[:value] = BankUtils.to_number(args.last, @spanish) if hash[:concepto] =~ /(Saldo Inicial del Periodo)/i
		params = parse_movement hash
		return Movement.new(params) if params
	end

	def parse_movement hash
		case hash[:concepto]
		when /ABONO (INTERES|CAPITAL) POR CORTE CUPON/i
			hash[:concepto] = 9007
		when /DIVIDENDO EN PESOS/i
			hash[:concepto] = 9006
		when /CARGO REG\. (CORTE CUPON|DIVIDENDO)/i
			hash[:concepto] = 9013
		when /INGRESO EN CTA CTE\./i
			hash[:concepto] = 9001
		when /EGRESO CUENTA CORRIENTE/i
			hash[:concepto] = 9002
		when /CANCELA DIVIDENDOS/i
			hash[:concepto] = 9002 # Puede cambiar en el futuro
		when /ABONO POR SORTEO LETRAS/i
			hash[:concepto] = 9005
		when /FACTURA VENTA R./i
			hash[:concepto] = 9995
		when /(FACTURA COMPRA R.)/i
			hash[:concepto] = 9994
		when /(Saldo Inicial del Periodo)/i
			hash[:concepto] = 0
		else
			hash[:concepto] = 9000
		end
		hash
	end
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 