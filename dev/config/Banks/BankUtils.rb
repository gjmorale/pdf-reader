module BankUtils

	def self.to_number str
		if str.is_a? Multiline
			str.strings.each do |line| 
				line.strip! unless line.empty?
				unless line.nil? or line.empty?
					str = line
					break
				end
			end
		end
		return 0.0 if str.nil? or str.empty?
		str = str.strip
		str = str.delete('$')
		str = str.delete(',')
		negative = (str.match /\(\$?\d+([.,]\d+)?\)/)
		str = str.delete('(')
		str = str.delete(')')
		str = str.delete('ST')
		str = str.delete('LT')
		if str == '—' or str == Result::NOT_FOUND
			return 0.0
		else
			num = str.to_f
			num = num*(-1) if negative
			num
		end
	end

	def self.to_amount number
		out = "$"
		integer_s = number.to_i.to_s
		integer_s.each_char.with_index do |d,i|
			if (integer_s.length-i)%3 == 0 and i != 0
				out << ','
			end
			out << d
		end
		out << ".#{(number%1*100).to_i.to_s}"
	end

	def self.to_arr(item, n)
		r = []
		n.times do |i|
			r << item
		end
		r
	end

	def self.check acumulated, stated
		if stated == 0
			puts "UNABLE TO CHECK #{to_amount(acumulated)}".yellow
			return
		end
		delta = acumulated - stated
		delta = delta * delta
		if delta > 1
			puts "CHECK #{to_amount(acumulated)} - #{to_amount(stated)}".red
			#raise CustomError::NO_MATCH
		else
			puts "CHECK #{to_amount(acumulated)} - #{to_amount(stated)}".green
		end
	end

	def self.clone_it field
		return nil if field.nil?
		if field.is_a? Array
			return field.map{|f| f.clone}
		else
			return field.clone
		end
	end

	def self.to_ai result
		return "0.0" if result.nil? or result.empty? or result.match(Regexp.new(Result::NOT_FOUND))
		if result.is_a? Multiline
			numbers = []
			result.strings.map{|s| numbers << s if s and not s.empty?}
			case numbers.size
			when 0
				return "0.0"
			when 1
				return "0.0"
			when 2
				return numbers[1]
			end	
		else
			return result
		end
	end

	def self.to_type str, type
		if str.is_a? Multiline and type
			str.strings.each do |s|
				if s.match(regex(type)) 
					return s
				end
			end
		else
			return str
		end
	end

	def self.parse_account str
		if str.is_a? Multiline
			str.strings.each do |s|
				return s if s.match /[0-9]{3}\-[0-9]{6}\-[0-9]{3}\+?/
			end
		else
			return str
		end
	end
end