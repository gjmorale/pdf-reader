

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

	puts to_amount(ARGV[0].to_f)