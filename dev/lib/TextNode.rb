class TextNode

	attr_accessor :xi
	attr_accessor :xf
	attr_accessor :y
	attr_reader :line

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

	def line= l
		if l.is_a? Array
			@line = Multiline.new(l)
		else
			@line = l
		end
	end

end