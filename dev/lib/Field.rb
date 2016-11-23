

class Field

	attr_accessor :position
	attr_reader :results
	attr_reader :ocurrence
	attr_reader :text
	attr_reader :width

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

end

class SingleField < Field

	attr_reader :page
	attr_reader :file

	def initialize(text, ocurrence, file, page, types, date = false)
		super text, ocurrence, date
		@file= file
		@page = page
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
	attr_reader :guide

	def initialize(text, ocurrence, order, type, guide = 0, date = false)
		super text, ocurrence, date
		@order = order
		@type = type
	end

	def <=> other
		@order <=> other.order
	end

	def execute(reader)
		reader.find(self)
	end

	def recalculate_position
		n = 0
		xi_min = position.xi
		xi_max = border.xi
		xf_min = position.xf
		xf_max = border.xf
		@results.each do |result|
			if(result.result != Result::NOT_FOUND)
				n += 1
				xi_min = [xi_min, result.position.xi].min 
				xi_max = [xi_max, result.edges.xi].max 
				xf_min = [xf_min, result.position.xf].max 
				xf_max = [xf_max, result.edges.xf].min 
			end
		end
		changed = (position.xi != xi_min or 
			       border.xi != xi_max or 
			       position.xf != xf_min or 
			       border.xf != xf_max)
		position.xi = xi_min
		border.xi = xi_max
		position.xf = xf_min
		border.xf = xf_max
		print_borders
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
		[border.xi, position.xi, position.xf, border.xf].each.with_index do |n,i|
			p_line << " "*(n - past_n -1) if n - past_n >= 1
			symbol = ">" if i < 2
			symbol = "<" if i >= 2
			p_line << symbol if n != past_n
			past_n = n
		end
		puts p_line << "             : #{text}"
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