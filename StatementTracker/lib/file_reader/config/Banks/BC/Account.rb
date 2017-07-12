class BC::Account < Account

	def initialize code
		@code = code
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end

end