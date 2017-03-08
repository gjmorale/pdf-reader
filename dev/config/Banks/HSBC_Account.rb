class AccountHSBC < Institution

	attr_accessor :value
	attr_reader :code
	attr_reader :name
	attr_reader :positions

	FAILS = [["AMPACTIVE", "AMP ACTIVE"]]

	def initialize code, name
		@name = unfail(name.strip)
		@code = code.strip
		@positions = []
	end

	def to_s
		"#{@code} - #{@name} : #{@value.round(2)}"
	end

	def inspect
		to_s
	end

	def add_pos pos
		@positions += pos if pos
	end

	def pos_value
		acumulated = 0
		@positions.map{|p| acumulated += p.value}
		return acumulated
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