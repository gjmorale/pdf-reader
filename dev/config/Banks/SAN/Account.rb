class SAN::Account < Account

	def initialize code, value
		@code = "Portfolio " + code[/\d+(?=USD - )/]
		@name = code
		@value = value
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end

end