class Position

	def initialize name, quantity, price, value, type
		@name = name
		@quantity = quantity
		@price = price
		@value = value
		@type = type
	end

	def to_s
		"#{@quantity*@price - @value}   =>   #{@name}[#{@quantity}]: $#{@value} - ($#{@price} c/u)"
	end

end