class Position

	attr_reader :value
	attr_reader :name

	def initialize name, quantity, price, value, extra = nil
		@name = name
		@quantity = quantity
		@price = price
		@value = value
		@extra = extra
	end

	def to_s
		add = @extra ? ": #{@extra}" : ""
		"#{@name}[#{@quantity}]: $#{@value} - ($#{@price} c/u) #{add}"
	end

	def print
		"#{@name};#{@quantity.to_s.sub('.',',')};#{@price.to_s.sub('.',',')};#{@value.to_s.sub('.',',')};#{@extra}\n"
	end

end