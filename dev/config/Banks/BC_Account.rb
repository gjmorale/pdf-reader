class AccountBC < Account

	def initialize code
		@code = code
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end

end