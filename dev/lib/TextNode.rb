class TextNode

	attr_accessor :xi
	attr_accessor :xf
	attr_accessor :y

	def initialize(xi, xf, y)
		@xi = xi
		@xf = xf
		@y = y
	end

	def to_s
		"[#{@xi}-#{@xf}, #{@y}]"
	end

	def inspect
		"[#{@xi}-#{@xf}, #{@y}]"
	end

	def coords
		[@xi, @xf, @y]
	end

end