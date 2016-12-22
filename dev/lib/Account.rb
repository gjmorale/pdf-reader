class Account

	attr_reader :name
	attr_reader :category
	attr_accessor :elements

	def initialize name, category = nil
		@name = name
		@category = category
		@elements = []
	end

	def to_s
		cat = @category.nil? ? "" : " [#{@category}]"
		"#{name}#{cat}: #{elements.size}"
	end

	def inspect
		to_s
	end

	def print
		"\n[#{@category}] #{@name}:"
	end
end