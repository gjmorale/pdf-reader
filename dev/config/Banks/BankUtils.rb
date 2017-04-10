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

	def self.to_arr(item, n)
		r = []
		n.times do |i|
			r << item
		end
		r
	end

	def self.check acumulated, stated
		if stated == 0
			puts "UNABLE TO CHECK #{acumulated}".yellow
			return
		end
		delta = acumulated - stated
		delta = delta * delta
		if delta > 1
			puts "CHECK #{acumulated.round(2)} - #{stated}".red
			#raise CustomError::NO_MATCH
		else
			puts "CHECK #{acumulated.round(2)} - #{stated}".green
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

	def self.parse_position str
		return [name, nil] unless str.is_a? Multiline
		name = str.strings[0]
		str.match /CUSIP/ do |m|
			code = str.strings[m.offset[2]][m.offset[0]..-1]
			return [code,name]
		end
		return [name,nil]
	end
end