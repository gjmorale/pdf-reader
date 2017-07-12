class Row

	attr_accessor :yi
	attr_accessor :yf 
	attr_accessor :lower_text 
	attr_accessor :upper_text

	def initialize i=nil, f=nil
		@yi = i if i
		@yf = f if f
	end

	def to_s
		"[#{yi}..#{yf}]"
	end

	def multiline?
		yi < yf
	end

	def width
		yf-yi + 1
	end

end