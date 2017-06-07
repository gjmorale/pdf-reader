class Account

	attr_reader :name
	attr_reader :code
	attr_accessor :value
	attr_reader :movements
	attr_reader :positions

	def initialize name, category = nil
		@name = name
		@category = category
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

	def add_mov mov
		@movements += mov if mov
	end

	def set_movs
		movements.map {|m| m.sec_1 = come}
	end

	def add_pos pos
		@positions += pos if pos if pos.is_a? Array
		@positions << pos if pos if pos.is_a? Position
	end

	def pos_value
		acumulated = 0
		@positions.map{|p| acumulated += p.value}
		return acumulated
	end

	def mov_value
		acumulated = 0
		@movements.map{|m| acumulated += m.value}
		return acumulated
	end

end