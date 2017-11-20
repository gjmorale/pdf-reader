class SAN::Movement < Movement

	attr_accessor :fecha
	attr_accessor :n_cuenta
	attr_accessor :i_financiera
	attr_accessor :concepto
	attr_accessor :monto
	attr_accessor :descripcion
	attr_accessor :value
	attr_accessor :detalle
	attr_accessor :forward_id
	attr_accessor :currency

	def initialize **args
		@fecha 			= args[:fecha] 	
		@n_cuenta 		= args[:n_cuenta] 
		@i_financiera 	= args[:i_financiera] 	|| SAN::LEGACY
		@concepto 		= args[:concepto] 		|| "Indefinido"
		@monto 			= args[:monto] 			|| 0.0
		@descripcion 	= args[:descripcion] 	|| ""
		@value 			= args[:value] 			|| 0.0
		@detalle 		= args[:detalle]	 	|| ""
		@forward_id 	= args[:forward_id]
		@currency 		= args[:currency]
	end

	def set_acc account
		@n_cuenta = account.code
	end

	def print

		out = "#{fecha}"
		out << ";#{n_cuenta}"
		out << ";#{i_financiera}"
		out << ";#{concepto}"
		out << ";#{monto.to_s.gsub('.',',')}"
		out << ";#{detalle}"
		out << ";#{currency}"
		out << ";#{descripcion};\n"
		out
	end

	def to_s
		"#{@fecha} #{@concepto}:#{@value}(#{@currency}) [#{@descripcion}] ... #{detalle}"
	end

	def inspect
		to_s
	end

	def merge other
		@descripcion << " por #{other.currency} #{other.value.abs}"
	end

end