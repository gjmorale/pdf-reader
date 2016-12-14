class Position

	attr_reader :value
	attr_reader :name

	def initialize name, quantity, price, value
		@name = name
		@quantity = quantity
		@price = price
		@value = value
	end

	def to_s
		"#{@name}[#{@quantity}]: $#{@value} - ($#{@price} c/u)"
	end

end