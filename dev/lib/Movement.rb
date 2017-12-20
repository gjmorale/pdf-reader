class Movement


	attr_accessor :fecha_movimiento
	attr_accessor :fecha_pago
	attr_accessor :concepto
	attr_accessor :factura
	attr_accessor :id_ti_valor1
	attr_accessor :id_ti1
	attr_accessor :id_sec1
	attr_accessor :id_fi1
	attr_accessor :cantidad1
	attr_accessor :id_ti_valor2
	attr_accessor :id_ti2
	attr_accessor :precio
	attr_accessor :cantidad2
	attr_accessor :delta
	attr_accessor :detalle
	attr_accessor :value

	def initialize **args
		@fecha_movimiento = clean args[:fecha_movimiento] || ""
		@fecha_pago = fecha_pago args[:fecha_pago] || @fecha_movimiento
		@concepto = args[:concepto] || "9000"
		@factura = clean args[:factura] || ""
		@id_ti_valor1 = clean args[:id_ti_valor1] || ""
		@id_ti1 = clean args[:id_ti1] || ""
		@id_sec1 = clean args[:id_sec1] || ""
		@id_fi1 = args[:id_fi1] || ""
		@cantidad1 = args[:cantidad1] || ""
		@id_ti_valor2 = clean args[:id_ti_valor2] || ""
		@id_ti2 = args[:id_ti2]
		@precio = args[:precio] || ""
		@cantidad2 = args[:cantidad2] || ""
		@delta = args[:delta] || ""
		@detalle = clean args[:detalle] || ""
		@value = args[:value] || 0.0
		@invalid = args[:invalid]
	end

	def valid?
		!@invalid
	end

	def fecha_pago fp
		fp.nil? or fp.inspect.strip.empty? or fp == Result::NOT_FOUND ? @fecha_movimiento :	fp
	end

	def clean v
		v.nil? or v.inspect.strip.empty? or v == Result::NOT_FOUND ? "" : v
	end

	def add_value v
		@value += v if v
		@cantidad2 = @value
	end

	def set_comision amount, currency
		@comision = amount
		@comision = currency
	end

	def print
		out = "#{@concepto}"
		out << ";#{@fecha_movimiento}"
		out << ";#{@fecha_pago}"
		out << ";#{@comision ? @comision.to_s.gsub('.',',') : ''}" #Monto Comision
		out << ";#{@comision_curr}" #Moneda Comision
		out << ";#{@factura}"
		out << ";#{@precio.to_s.gsub('.',',')}"
		out << ";#{@id_ti_valor1}"
		out << ";#{@id_ti1}"
		out << ";#{@id_sec1}"
		out << ";#{@id_fi1}" #IF
		out << ";#{@cantidad1.to_s.gsub('.',',')}"
		out << ";#{@id_ti_valor2}"
		out << ";#{@id_ti2}"
		out << ";" #{@id_sec2}"
		out << ";" #{@id_fi2}"
		out << ";#{@cantidad2.to_s.gsub('.',',')}"
		out << ";#{@detalle};\n"
		out
	end

	def to_s
		"#{@fecha_movimiento} #{@concepto}:#{@id_ti_valor1}(#{@id_ti_valor2}) [#{@cantidad1};#{@precio};#{value}] ... #{detalle}"
	end

	def inspect
		to_s
	end
end