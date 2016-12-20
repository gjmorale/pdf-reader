class AccountColmena < Account
	def initialize(title, category, type)
		super(title, category)
		@type = type
	end

	def print
		"\n[#{@type}] #{@category}: #{@title}"
	end
end