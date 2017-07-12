class Movement

	attr_accessor :value
	attr_accessor :detalle
	attr_accessor :id_sec1

	def initialize **args
		@fecha_movimiento = clean args[:fecha_movimiento] || ""
		@fecha_pago = fecha_pago args[:fecha_pago] || @fecha_movimiento
		@concepto = args[:concepto] || "9000"
		@id_sec1 = clean args[:id_sec1] || ""
		@factura = clean args[:factura] || ""
		@id_ti_valor1 = clean args[:id_ti_valor1] || ""
		@id_fi1 = args[:id_fi1] || ""
		@cantidad1 = args[:cantidad1] || ""
		@id_ti_valor2 = clean args[:id_ti_valor2] || ""
		@id_ti2 = args[:id_ti2]
		@precio = args[:precio] || ""
		@cantidad2 = args[:cantidad2] || ""
		@delta = args[:delta] || ""
		@detalle = clean args[:detalle] || ""
		@value = args[:value] || 0.0
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

	def print
		out = "#{@concepto}"
		out << ";#{@fecha_movimiento}"
		out << ";#{@fecha_pago}"
		out << ";" #Monto Comision
		out << ";" #Moneda Comision
		out << ";#{@factura}"
		out << ";#{@precio.to_s.gsub('.',',')}"
		out << ";#{@id_ti_valor1}"
		out << ";" #id_ti1
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