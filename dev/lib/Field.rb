class Result

	NOT_FOUND = "Result not found"

	attr_accessor :position
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

class Field

	attr_accessor :position
	attr_reader :results
	attr_reader :ocurrence
	attr_reader :text

	def initialize(text, ocurrence, date = false)
		@text = text
		@ocurrence = ocurrence
		@date = date
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
		@text = text
		@ocurrence = ocurrence
		@file= file
		@page = page
		@results = []
		types.each do |type|
			@results << Result.new(type)
		end
		@date = date
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

	def initialize(text, ocurrence, order, type, date = false)
		@text = text
		@ocurrence = ocurrence
		@order = order
		@type = type
		@date = date
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

end