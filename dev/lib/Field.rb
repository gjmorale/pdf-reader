

class Field

	attr_accessor :position
	attr_reader :results
	attr_reader :orientation
	attr_reader :text
	attr_accessor :width
	attr_reader :max_length

	def initialize(text, width = 1, orientation = Setup::Table.header_orientation, date = false)
		if text.is_a? Array
			@text = Multiline.generate text, true 
		elsif text.is_a? Multiline
			@text = Multiline.generate text.strings, true 
		else
			@text = text if text
		end
		@orientation = orientation
		@date = date
		@width = width
	end

	def clone
		Field.new(@text,@width,@orientation,@date)
	end

	def position?
		not @position.nil?
	end

	def regex
		if @width > 1 and not @text.is_a? Multiline
			#puts "expanded"
			@text = Multiline.generate ["#{@text}"]
		elsif @width == 1 and @text.is_a? Multiline
			#puts "reduced #{self}"
			if @text.strings.size == 1
				@text = @text.strings[0].dup
			else
				raise RangeError, "Multiline field was reduced beyond bounds"
			end
		end 
		RegexHelper.regexify @text, @date
	end

	def to_s
		text = @text
		text << "[DATE]" if @date
		text
	end

	def inspect 
		to_s
	end

	def execute(reader)
		if reader.move_to(self)
			reader.skip self
		else
			return false
		end
	end

	def print_results
		#Nothing by default
	end

	def top
		position.y
	end

	def bottom
		position.y + width - 1
	end

	def left
		position.xi
	end

	def right
		position.xf
	end

	def left= value
		position.xi = value
	end

	def right= value
		position.xf = value
	end
end

class SingleField < Field

	attr_accessor :enforced_width
	attr_accessor :types

	def initialize(text, types, width = 1, orientation = Setup::Table.header_orientation, date = false)
		super text, width, orientation, date
		@results = []
		types.each do |type|
			@results << Result.new(type)
		end
		@enforced_width = (width > 1)
	end

	def clone
		SingleField.new(@text, @types, @width, @orientation, @date)
	end

	def print_results
		line = "|#{@text}: "
		results.each do |r|
			line << "#{r.result.strip} | "
		end
		puts ("+"<<"-"*(line.length-3)<<"+").green
		puts line.green
		puts ("+"<<"-"*(line.length-3)<<"+").green
	end

	def execute(reader)
		if reader.move_to(self)
			reader.find_results_for(self)
			reader.skip self
			return true
		else
			return false
		end
	end
end

class HeaderField < Field

	attr_reader :type
	attr_reader :order
	attr_accessor :border

	def initialize(text, order, type, guide = false, width = 1, orientation = Setup::Table.header_orientation, max_l = nil, date = false)
		super text, width, orientation, date
		@order = order
		@type = type
		@guide = guide
		@max_length = max_l
	end

	def clone 
		HeaderField.new(@text, @order, @type, @guide, @width, @orientation, @max_length, @date)
	end

	def guide?
		@guide
	end

	def <=> other
		@order <=> other.order
	end

	def execute(reader)
		reader.find(self)
	end

	def recalculate_position(o_l = true, i_l = true, i_r = true, o_r = true)
		#puts "#{self}[#{outer_left}(#{left} #{right})#{outer_right}]"
		xi_min = left
		xi_max = outer_left
		xf_min = right
		xf_max = outer_right
		@results.each do |result|
			if(result.result != Result::NOT_FOUND)
				xi_min = [xi_min, result.left].min if i_l
				xi_max = [xi_max, result.edges.xi].max if o_l
				xf_min = [xf_min, result.right].max if i_r
				xf_max = [xf_max, result.edges.xf].min if o_r
			end
		end
		changed = (left != xi_min or 
			       outer_left != xi_max or 
			       right != xf_min or 
			       outer_right != xf_max)
		self.left = xi_min
		self.outer_left = xi_max
		self.right = xf_min
		self.outer_right = xf_max
		#print_borders
		#puts "#{self}[#{outer_left}(#{left} #{right})#{outer_right}] => #{changed}"
		changed
	end

	def set_results(rows)
		@results = []
		rows.times do |i|
			result = Result.new(type)
			result.position = position.dup
			result.edges = border.dup
			result.result = Result::NOT_FOUND
			@results << result
		end
	end

	def reset_results
		results.each do |result|
			result.position = position.dup
			result.edges = border.dup
		end
	end

	def print_borders
		p_line = " "
		past_n = 0
		[outer_left, left, right, outer_right].each.with_index do |n,i|
			p_line << " "*(n - past_n -1) if n - past_n >= 1
			symbol = ">" if i < 2
			symbol = "<" if i >= 2
			p_line << symbol if n != past_n
			past_n = n
		end
		puts p_line << "         :[#{outer_left} ( #{left} : #{right} ) #{outer_right}] #{text}"
	end

	def outer_left
		border.xi
	end

	def outer_right
		border.xf
	end

	def outer_left= value
		border.xi = value
	end

	def outer_right= value
		border.xf = value
	end

end

class Result < Field

	NOT_FOUND = "Result not found"

	attr_accessor :result
	attr_accessor :edges
	attr_reader :type

	def initialize(type)
		@type = type
	end

	def regex
		if @type.is_a? Array
			r = @type.map {|type| Setup.inst.get_regex(type)}
		else
			r = Setup.inst.get_regex(@type)
		end
		r
	end

	def to_s
		@result
	end

	def inspect 
		to_s
	end

	def result= value
		value.delete "\n"
		@result = value
	end

	def outer_left
		edges.xi
	end

	def outer_right
		edges.xf
	end

	def outer_left= value
		edges.xi = value
	end

	def outer_right= value
		edges.xf = value
	end

end