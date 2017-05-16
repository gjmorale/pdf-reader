class CrediCorp::Account < Account

	attr_accessor :value
	attr_accessor :positions
	attr_reader :code

	def initialize code, value
		@value = value
		@positions = []
		@movements = []
	end

	def value_s
		@value.to_s.sub(".",",")
	end
end