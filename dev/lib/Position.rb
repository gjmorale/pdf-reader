class Position

	attr_reader :value

	def initialize name, quantity, price, value
		@name = name
		@quantity = quantity
		@price = price
		@value = value
	end

	def to_s
		"#{@quantity*@price - @value}   =>   #{@name}[#{@quantity}]: $#{@value} - ($#{@price} c/u)"
	end

end