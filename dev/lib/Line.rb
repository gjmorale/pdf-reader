class MultiMatchData
	attr_accessor :offset
	attr_accessor :width

	def initialize 
		@offset = []
	end

	def offset index = 0
		@offset
	end
end

class Multiline < String
	attr_reader :line_size
	attr_reader :strings

	def self.generate str
		if str.is_a? Array
			return line = Multiline.new(str)
		else
			return str
		end
	end

	def initialize(strings)
		legacy = ""
		strings.each do |s|
			legacy << s
		end
		super legacy
		@inline = legacy
		@strings = strings
		@line_size = strings.size
	end

	def length
		max = 0
		@strings.each do |s|
			max = s.length if s.length > max
		end
		max
	end

	def to_s
		out = ""
		@strings.each do |s|
			out << s
		end
		out
	end

	def [] key
		if key.is_a? Range
			r = []
			@strings.each do |string|
				r << string[key]
			end
			return Multiline.new(r) 
		else
			super[key]
		end

	end

	def match regex
		return false unless regex
		if regex.is_a? Array
			return nil if @strings.size < regex.size
			matches = [] 
			index = 0
			y = 0
			@strings.each do |s|
				s.match regex[index] {|m|
					matches << [m.offset(0)[0], m.offset(0)[1], y]
					index +=1
					break if index == regex.size
				}
				y += 1
			end
			return false if index != regex.size
			if block_given?
				m = MultiMatchData.new
				m.offset[0] = matches.map {|match| match[0]}.min
				m.offset[1] = matches.map {|match| match[1]}.max
				m.width = y
				yield(m) 
			else
				true
			end
		else
			return super regex
		end
	end

	def index regex, offset=0
		first = nil
		@strings.each do |s|
			last = s.index(regex, offset)
			first = last if last and (not first or first > last)
		end
		return first
	end

	def rindex regex, offset=0
		first = nil
		@strings.each do |s|
			last = offset == 0 ? s.rindex(regex) : s.rindex(regex, offset)
			first = last if last and (not first or first < last)
		end
		return first
	end

	def delete regex
		inline = ""
		@strings.each do |s|
			inline << s.delete(regex)
		end
		inline
	end

	def nil?
		return true if @strings.nil? or @inline.nil?
		@strings.each do |s|
			return true if s.nil?
		end
		return false
	end

	def empty?
		@strings.size == 0 or @inline.empty?
	end
end