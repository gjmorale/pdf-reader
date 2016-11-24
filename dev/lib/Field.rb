

class Field

	attr_accessor :position
	attr_reader :results
	attr_reader :ocurrence
	attr_reader :text
	attr_accessor :width

	def initialize(text, width = 1, ocurrence = 1, date = false)
		@text = Multiline.generate text
		@ocurrence = ocurrence
		@date = date
		@width = width
	end

	def position?
		not @position.nil?
	end

	def regex
		if @width > 1 and not @text.is_a? Multiline
			puts "expanded"
			@text = Multiline.generate ["#{@text}"]
		elsif @width == 1 and @text.is_a? Multiline
			puts "reduced"
			 if @text.size == 1
			 	@text = @text[0]
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
		reader.move_to(self)
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

	def initialize(text, types, width = 1, ocurrence = 1, date = false)
		super text, width, ocurrence, date
		@results = []
		types.each do |type|
			@results << Result.new(type)
		end
	end

	def print_results
		line = "|#{@text}: "
		results.each do |r|
			line << "#{r.result.strip} | "
		end
		puts "-"*line.length
		puts line
		puts "-"*line.length
	end

	def execute(reader)
		reader.move_to(self)
		reader.find_results_for(self)
	end
end

class HeaderField < Field

	attr_reader :type
	attr_reader :order
	attr_accessor :border

	def initialize(text, order, type, guide = false, width = 1, ocurrence = 1, date = false)
		super text, width, ocurrence, date
		@order = order
		@type = type
		@guide = guide
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

	def recalculate_position
		n = 0
		print "[#{outer_left}(#{left} #{right})#{outer_right}]"
		xi_min = left
		xi_max = outer_left
		xf_min = right
		xf_max = outer_right
		@results.each do |result|
			if(result.result != Result::NOT_FOUND)
				n += 1
				xi_min = [xi_min, result.left].min 
				xi_max = [xi_max, result.edges.xi].max 
				xf_min = [xf_min, result.right].max 
				xf_max = [xf_max, result.edges.xf].min 
			end
		end
		changed = (left != xi_min or 
			       outer_left != xi_max or 
			       right != xf_min or 
			       outer_right != xf_max)
		left = xi_min
		outer_left = xi_max
		right = xf_min
		outer_right = xf_max
		print_borders
		print "[#{outer_left}(#{left} #{right})#{outer_right}] => #{changed}"
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
		puts p_line << "             : #{text}"
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

	def initialize(type)
		@type = type
	end

	def regex
		Setup.bank.get_regex(@type)
	end

	def to_s
		@result
	end

	def inspect 
		to_s
	end

end