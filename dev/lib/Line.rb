class Multiline < String
	attr_reader :line_size

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
		return @inline.match regex
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
		@strings.nil? or @inline.nil?
	end

	def empty?
		@strings.size == 0 or @inline.empty?
	end
end