class Position

	attr_reader :name
	attr_reader :quantity
	attr_accessor :price
	attr_accessor :code
	attr_reader :value

	def initialize name, quantity, price, value, extra = nil
		@name = name.strip unless name.nil?
		@quantity = quantity
		@price = price
		@value = value
		@extra = extra.strip unless extra.nil?
	end

	def to_s
		add = @extra ? ": #{@extra}" : ""
		"#{@name}[#{@quantity}]: $#{@value} - ($#{@price} c/u) #{add}"
	end

	def print
		"#{@name};#{@quantity.to_s.sub('.',',')};#{@price.to_s.sub('.',',')};#{@value.to_s.sub('.',',')};#{@extra}\n"
	end

end 