class SIGA::Account < Account

	def initialize code, value
		@code = code
		@value = value
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end

	def adjust_movs
		sell_movs = movements.select{|m| m.concepto == 9995}
		buy_movs = movements.select{|m| m.concepto == 9994}
		(sell_movs+buy_movs).each{|m| movements.delete m }
		prorate buy_movs, 9004, "COMPRAS"
		prorate sell_movs, 9005, "VENTAS"
	end

	private 

		def prorate collection, concept, title = nil
			collection.each do |m|
				m.factura = m.factura.gsub(/\./,'')
				movs = movements.select{|n| n.concepto == concept and n.factura == m.factura }
				n = movs.inject(0){|t,i| t + i.cantidad2}
				q = (m.cantidad2 and m.cantidad2.is_a? Numeric) ? m.cantidad2 : m.cantidad1
				movs.each do |mov|
					comision = ((q-n)*mov.cantidad2/n).round(0)
					mov.set_comision comision, "CLP"
				end
			end
		end

end