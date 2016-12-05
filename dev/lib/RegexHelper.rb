class RegexHelper

	def self.wildchar
		@@wildchar ||= Setup::Read.wildchar
	end

	def self.date_format
		@@date_format ||= Setup::Read.date_format
	end

	def self.reset
		@@wildchar = nil
		@@date_format = nil
	end

	def self.strip_wildchar str
		return "" if (str.nil? or str.empty?)
		r = str.delete(wildchar)
		r = r.delete('\n')
	end

	def self.index str, offset = 0, absence = true
		arg = absence ?  "[^#{wildchar}]" : "#{wildchar}"
		regex = Regexp.new(arg)
		str.index(regex, offset)
	end

	def self.rindex str, offset = 0, absence = true
		arg = absence ?  "[^#{wildchar}]" : "#{wildchar}"
		regex = Regexp.new(arg)
		offset == 0 ? str.rindex(regex) : str.rindex(regex, offset)
	end



	def self.regexify term, date = false
		if term.is_a? Multiline
			return term.strings.map{|s| regexify s}
		end
		#term = term.to_s
		raise if term.empty?
		term = Regexp.escape term
		regex = ""
		skip = true
		term.each_char do |char|
			unless char == wildchar
				regex << "#{wildchar}*" unless skip
				skip = (char == "\\")
				regex << char
			end
		end
		if date
			regex << "#{wildchar}*" unless skip
			regex << " #{date_format}"
		end
		Regexp.new(regex)
	end

	def self.regexify_skips skips
		regex = ""
		regex << '^('
		first = true
		skips.each do |skip|
			first ? (first = false) : regex << '|'
			regex << Regexp.escape(skip)
		end
		regex << '){1}$'
		Regexp.new regex
	end
end