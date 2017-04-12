class HSBCAssetTable < AssetTable

	def self.parse_position str, type
		extra = ""
		regex = '\('<< type <<'\)'
		regex = Regexp.new(regex)
		str.strings.each do |s|
			if s.match regex
				code = "#{type} #{s[0..s.index(' ')-1]}"
				return [code, extra]
			else
				extra << s
			end
		end
		return [extra,nil]
	end

	def self.parse_account str
		str = str.inspect
		account_data = []
		str.match(get_regex Custom::ACCOUNT_CODE, false) {|m|
			account_data[0] = str[m.offset(0)[0]..m.offset(0)[1]-1]
			account_data[1] = str[m.offset(0)[1]..-1]
		}
		return account_data
	end

	def new_position titles, quantity, price, value, ai
		Position.new(titles[0], 
			BankUtils.to_number(quantity), 
			BankUtils.to_number(BankUtils.to_type(price, Custom::LONG_AMOUNT)), 
			BankUtils.to_number(value) + BankUtils.to_number(ai),
			titles[1])
	end


end