class SAN1::Account < Account

	def initialize code, value
		@code = code
		@value = value
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end

end