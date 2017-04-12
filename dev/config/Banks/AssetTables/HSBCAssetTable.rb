class HSBCAssetTable < AssetTable

	attr_reader :account_title

	def pre_load *args
		@account_title = args[0][0] if args.any?
		@label_index = 2
		@title_limit = 0
		@iterative_title = true
	end

	def post_load
		unless account_title and not account_title.empty?
			puts "LIMITED #{account_title}" if verbose
			@title_limit = 2
		end
	end

	def parse_position str, type
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

	def parse_account str
		str = str.inspect
		account_data = []
		str.match(/\d{3}[A-Z]\d{7}/) {|m|
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