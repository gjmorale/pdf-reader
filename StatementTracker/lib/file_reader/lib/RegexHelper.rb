class RegexHelper

	def self.wildchar
		'¶'
	end

	def self.date_format
		/\d{2}(\/\d{2}){2}\d{2}/
	end

	def self.strip_wildchar str
		return "" if (str.nil? or str.empty?)
		r = str.delete(wildchar)
		r = r.delete("\n")
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
		if term =~ /^\[.+(\|.+)+\]$/
			rgx = Regexp.union term[1..-2].split('|').map{|r| regexify r}
			#puts rgx
			return rgx
		end
		#term = term.to_s
		raise if term.empty?
		#puts "#{term}"
		term = Regexp.escape term
		regex = ""
		skip = true
		term.each_char do |char|
			if char == wildchar
				regex << "#{wildchar}*.?"
			else
				regex << "#{wildchar}*" unless skip
				skip = (char == "\\")
				regex << char
			end
		end
		if date
			regex << "#{wildchar}*" unless skip
			regex << " #{date_format}"
		end
		#puts "[[#{regex}]]"
		Regexp.new(regex)
	end

	def self.regexify_skips skips
		regex = ""
		regex << '('
		first = true
		skips.each do |skip|
			first ? (first = false) : regex << '|'
			regex << skip
		end
		regex << '){1}'
		Regexp.new regex
	end
end