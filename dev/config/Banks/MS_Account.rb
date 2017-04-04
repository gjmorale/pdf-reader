class AccountMS < Account

	attr_accessor :value
	attr_accessor :positions
	attr_reader :code

	def initialize code, value
		@code = code.strip.sub('+','')
		@value = value
		@positions = []
	end

	def to_s
		"#{@code} : #{@value.round(2)}"
	end

	def value_s
		@value.to_s.sub(".",",")
	end

	def inspect
		to_s
	end

	def pos_value
		acumulated = 0
		positions.map{|p| acumulated += p.value}
		acumulated
	end

	def add_pos pos
		if pos
			pos.reverse!
			@positions += pos
		end
	end

end