class AccountHSBC < Account

	attr_accessor :value
	attr_reader :code
	attr_reader :name
	attr_reader :positions

	FAILS = [["AMPACTIVE", "AMP ACTIVE"]]

	def initialize code, name
		if @consolidated = name.nil?
			@name = "CONSOLIDATED ACCOUNT"
		else
			@name = unfail(name.strip)
		end
		@code = code.strip
		@positions = []
	end

	def title
		if @consolidated
			return ""
		else
			return " - Portfolio #{@code} - #{@name}"
		end
	end

	def to_s
		"#{@code} - #{@name}"
	end

	def value_s
		@value.to_s
	end

	def inspect
		to_s
	end

	def unfail original
		FAILS.each do |fail|
			if original.match fail[0]
				return original.gsub(fail[0], fail[1])
			end
		end
		return original
	end

end