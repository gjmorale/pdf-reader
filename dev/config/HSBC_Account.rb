class AccountHSBC < Account

	attr_accessor :value
	attr_reader :code
	attr_reader :name

	def initialize code, name
		@name = name.strip
		@code = code.strip
	end

	def to_s
		"#{@code} - #{@name} : #{@value.round(2)}"
	end

	def inspect
		to_s
	end

end