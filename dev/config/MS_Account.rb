class AccountMS < Account

	attr_accessor :value
	attr_reader :code

	def initialize code, value
		@code = code.strip
		@value = value
	end

	def to_s
		"#{@code} : #{@value.round(2)}"
	end

	def inspect
		to_s
	end

end