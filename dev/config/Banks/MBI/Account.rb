class MBI::Account < Account

	def initialize code, value
		@value = value
		@code = code
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s
	end
end