class AccountColmena < Account
	def initialize(title, category)
		super(title, category)
	end

	def print
		"\n[#{@category}] #{@name}:"
	end
end