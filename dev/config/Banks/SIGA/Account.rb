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
		#raise
	end

	private 

		def prorate collection, concept, title = nil
			puts title
			collection.each do |m|
				m.factura = m.factura.gsub(/\./,'')
				movs = movements.select{|n| n.concepto == concept and n.factura == m.factura }
				puts "#{m.factura}->#{movs.size}"
				n = movs.inject(0){|t,i| t + i.cantidad2}
				r = m.cantidad2/n
				movs.each do |mov|
					comison = r*mov.cantidad2
					mov.add_value comision
					mov.set_comision comision, "CLP"
				end
			end
		end

end