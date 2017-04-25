class AccountSEC < Account

	attr_accessor :value
	attr_accessor :positions
	attr_reader :code

	def initialize code, value
		@value = value
		@positions = []
		@movements = []
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

	def add_pos pos
		@positions += pos if pos
	end

end