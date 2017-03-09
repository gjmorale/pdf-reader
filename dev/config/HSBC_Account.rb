class AccountHSBC < Account

	attr_accessor :value
	attr_reader :code
	attr_reader :name

	def initialize code, name
		if code == ""
			@name = nil
			@code = nil
		else
			@name = name.strip
			@code = code.strip
		end
	end

	def title_2
		if @name.nil? or @code.nil?
			return ""
		else
			return " - Portfolio #{@code} - #{@name}}"
		end
	end

	def to_s
		"#{@code} - #{@name}}"
	end

	def inspect
		to_s
	end

end