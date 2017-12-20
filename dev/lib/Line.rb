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

	def self.generate str, remove_n = true
		if str.is_a? Array
			str = str.map {|s| s = s.delete("\n")} if remove_n
			return  Multiline.new(str)
		else
			return str
		end
	end

	def initialize(strings)
		legacy = ""
		strings.each do |s|
			legacy << s if s
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
			out << "\n" unless out == ""
			out << s 
		end
		out
	end

	def inspect
		out = ""
		@strings.each do |s|
			out << s 
		end
		out
	end

	def [] key, limit = nil
		if key.is_a? Range
			r = []
			@strings.each do |string|
				r << string[key]
			end
			return Multiline.new(r) 
		elsif limit
			r = []
			@strings.each do |string|
				r << string[key, limit]
			end
			return Multiline.new(r) 
		else
			super[key]
		end

	end

	def match regex, &block
		return false unless regex
		if regex.is_a? Array
			return nil if @strings.size < regex.size
			matches = [] 
			index = 0
			yi = -1
			yf = 0
			@strings.each.with_index do |s, i|
				s.match regex[index] {|m|
					matches << [m.offset(0)[0], m.offset(0)[1]]
					index +=1
					yi = i if yi == -1
					yf = i
				}
				break if index == regex.size
			end
			return false if index != regex.size
			if block_given?
				m = MultiMatchData.new
				m.offset[0] = matches.map {|match| match[0]}.min
				m.offset[1] = matches.map {|match| match[1]}.max
				m.offset[2] = yi
				m.offset[3] = yf
				block.call(m) 
			else
				true
			end
		else
			if block_given?
				return match([regex], &block)
			end
			return match [regex]
		end
	end

	def multi_match regex
		return false unless regex or @string.size > 0
		scope = Array.new(@strings.size, false)
		@strings.each.with_index do |s, i|
			scope[i] = s.match regex
		end
		return scope
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
			last = (offset == 0 ? s.rindex(regex) : s.rindex(regex, offset))
			first = last if last and (not first or first < last)
		end
		return first
	end

	def delete regex
		stripped = []
		@strings.each do |s|
			stripped << s.delete(regex)
		end
		Multiline.new(stripped)
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

	def << value
		#puts "#{self} << #{value}"
		if value.is_a? Multiline
			#puts "#{value} is a multiline"
			@strings.each.with_index do |s, i|
				s << value.strings[i] if value.strings[i]
				#puts "#{s}"
			end
		else
			#puts "#{value} is not a multiline"
			@strings.each.with_index do |s, i|
				s << value
				#puts "#{s}"
			end
		end
		#puts "INSIDE"
		#return Multiline.new @strings
	end

	def fill
		max = length
		@strings.each do |s|
			offset = (s.chars[0] == "\n" ? 1 : 0)
			s << " " while s.length < max + offset
		end
	end

	def append value
		if value.is_a? Multiline
			lines = @strings + value.strings
			Multiline.generate(lines)
		else
			self << value
		end
	end
end

class String
  # colorization
  def colorize(color_code, style_code = 0)
    "\e[#{color_code}m#{self}\e[#{style_code}m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def green_bg
    colorize(1,1)
  end
end