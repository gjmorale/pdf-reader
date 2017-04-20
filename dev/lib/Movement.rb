class Movement
	def initialize **args
		@fecha_movimiento = clean args[:fecha_movimiento] 
		@fecha_pago = fecha_pago args[:fecha_pago] 
		@id_sec1 = clean args[:id_sec1] 
		@factura = clean args[:factura] 
		@id_ti_valor1 = clean args[:id_ti_valor1] 
		@cantidad1 = args[:cantidad1]
		@id_ti_valor2 = clean args[:id_ti_valor2] 
		@precio = args[:precio]
		@cantidad2 = args[:cantidad2]
		@delta = args[:delta] 
		@detalle = args[:concepto]
		@concepto = concepto args[:concepto] 
	end

	def fecha_pago fp
		fp.nil? or fp.inspect.strip.empty? or fp == Result::NOT_FOUND ? @fecha_movimiento :	fp
	end

	#SEC specific
	def concepto c
		if c =~ /(Venta|Rescate|Sorteo)/i
			codigo = 9005
			@signo = -1
		elsif c =~ /(Compra|Inversi.n)/i
			codigo = 9004
			@signo = 1
		elsif c =~ /(Dividendo)/i
			codigo = 9006
			@signo = 1
		elsif c =~ /(Corte Cup[oóOÓ]n)/i
			codigo = 9007
			@signo = -1
			@cantidad1 = 0.0
		else
			codigo = 9000
			@signo = 1
		end
		codigo
	end

	def clean value
		value.nil? or value.inspect.strip.empty? or value == Result::NOT_FOUND ? "" : value
	end

	def value
		@cantidad2 + @signo*@delta
	end

	def print
		out = "#{@fecha_movimiento}"
		out << ";#{@fecha_pago}"
		out << ";#{@concepto}"
		out << ";#{@id_sec1}"
		out << ";#{@factura}"
		out << ";#{@id_ti_valor1}"
		out << ";#{@cantidad1.to_s.gsub('.',',')}"
		out << ";#{@id_ti_valor2}"
		out << ";#{@precio.to_s.gsub('.',',')}"
		out << ";#{value.to_s.gsub('.',',')}"
		out << ";#{@detalle};\n"
		out
	end

	def to_s
		"#{@fecha_movimiento} #{@concepto}:#{@id_ti_valor1}(#{@id_ti_valor2}) [#{@cantidad1};#{@precio};#{value}]"
	end

	def inspect
		to_s
	end
end

class CashMovement < Movement
	def initialize **args
		@fecha_movimiento = clean args[:fecha_movimiento] 
		@fecha_pago = fecha_pago args[:fecha_pago] 
		@id_sec1 = clean args[:id_sec1] 
		@id_ti_valor1 = clean args[:id_ti_valor1] 
		@cantidad1 = args[:cantidad1]
		@detalle = args[:detalle]
		@concepto = concepto 
	end

	def print
		out = "#{@fecha_movimiento}"
		out << ";#{@fecha_pago}"
		out << ";#{@concepto}"
		out << ";#{@id_sec1}"
		out << ";"
		out << ";#{@id_ti_valor1}"
		out << ";#{value.to_s.gsub('.',',')}"
		out << ";"
		out << ";"
		out << ";"
		out << ";#{@detalle};\n"
		out
	end

	#SEC specific
	def concepto
		if @cantidad1 > 0
			codigo = 9001
			@signo = 1
		elsif @cantidad1 < 0
			codigo = 9002
			@signo = -1
		else
			codigo = 9000
			@signo = 0
		end
		codigo
	end

	def value
		@signo*@cantidad1
	end

	def to_s
		"#{@fecha_movimiento} #{@concepto}:#{@detalle}(#{@id_ti_valor1}) [#{value}]"
	end
end