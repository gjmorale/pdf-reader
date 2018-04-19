class SAN1::TransactionTable < TransactionTable

	def pre_load *args
		super
		@title_limit = 0
		@spanish = true
	end

	def new_movement args
		args = args.map{|arg| "#{arg}".strip}
		hash = {
			fecha_movimiento: index_or_default(args, @mov_map[:fecha_movimiento]),
			fecha_pago: index_or_default(args, @mov_map[:fecha_pago]),
			factura: index_or_default(args, @mov_map[:factura]),
			concepto: index_or_default(args, @mov_map[:concepto]),
			id_ti_valor1: index_or_default(args, @mov_map[:id_ti_valor1]), #CLP
			id_ti1: index_or_default(args, @mov_map[:id_ti1]),
			cantidad1: BankUtils.to_number(index_or_default(args, @mov_map[:cantidad1]), spanish),
			id_ti_valor2: index_or_default(args, @mov_map[:id_ti_valor2]),
			id_ti2: index_or_default(args, @mov_map[:id_ti2]),
			precio: BankUtils.to_number(index_or_default(args, @mov_map[:precio]), spanish),
			cantidad2: BankUtils.to_number(index_or_default(args, @mov_map[:cantidad2]), spanish),
			detalle: index_or_default(args, @mov_map[:detalle]),
			value: @mov_map[:value] && BankUtils.to_number(index_or_default(args, @mov_map[:value]), spanish)
		}
		params = parse_movement hash
		return Movement.new(params) if params
	end

	def index_or_default args, value
		value.is_a?(Integer) ? args[value] : value
	end

	def parse_movement hash
		hash[:fecha_pago] = hash[:fecha_movimiento] if (hash[:fecha_pago] =~ /Result not found/)
		hash[:value] ||= hash[:cantidad2]
		hash
	end
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 
