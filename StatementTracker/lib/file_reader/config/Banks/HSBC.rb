class HSBC < Institution
	DIR = "HSBC"
	LEGACY = "HSBC"
end

Dir[File.dirname(__FILE__) + '/HSBC/*.rb'].each {|file| require_relative file }

HSBC.class_eval do

	def dir 
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		ACCOUNT_CODE = -1
		LONG_AMOUNT = -2
		GLITCH_AMOUNT = -3
	end

	TABLE_OFFSET = 15
	CENTER_MASS_LIMIT = 0.0
	VERTICAL_SEARCH_RANGE = 8

	def initialize
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d)\.\d{2}%'
		when Setup::Type::AMOUNT
			'[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2,4}'
		when Setup::Type::INTEGER
			'[+-]?[1-9]\d{0,2}(?:,+?[0-9]{3})*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*'
		when Setup::Type::DATE
			'\(?\d{2}\/\d{2}\/\d{4}\)?'
		when Custom::ACCOUNT_CODE
			'\d{3}[A-Z]\d{7}'
		when Custom::LONG_AMOUNT
			'[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]+'
		when Custom::GLITCH_AMOUNT
			'(.*)'
		when Setup::Type::FLOAT
			'[1-9]\d+\.\d{6}'
		end
	end

	private

		def set_date value
			month = -1
			Institution::MONTHS.each do |m|
				if value =~ m[1]
					month = m[0]
					break
				end
			end
			day = value[0..value.index(' ')-1]
			year = value[value.rindex(' ')+1..-1].strip
			@date_out = "#{day}-#{month}-#{year}"
		end

		def analyse_index file
			@reader = Reader.new(self, file)
			owner = nil
			set_date @reader.find_text(/^\d{1,2} [A-Z]{4,10} 20\d{2}/)
			header = HeaderField.new("HSBC Private Bank(Suisse)",1,Setup::Type::LABEL)
			if header.execute @reader
				xi = header.left < self.offset ? 0 : header.left + self.offset
				xf = header.right + 150
				y = header.top
				header.border = TextNode.new(xi, xf, y)
				row = Row.new(y-40, y-1)
				header.set_results(1)
				@reader.get_columns([header],[row])
				owner = header.results[0].result.inspect.strip
				owner = nil if owner.empty?
			end
			return [owner, @date_out]
		end

		def analyse_position file
			@reader = Reader.new(self, file)
			set_date @reader.find_text(/^\d{1,2} [A-Z]{4,10} 20\d{2}/)
			@accounts = recognize_accounts
			@accounts.each do |account|
				puts "\nACC: #{account.code} - $#{account.value}"
				account.add_pos liquidity_for(account)
				account.add_pos fixed_income_for(account)
				account.add_pos equity_for(account)
				account.add_pos hedge_funds_for(account)
				account.add_pos private_equity_for(account)
				account.add_pos real_estate_for(account)
				account.add_pos others_for(account)
				puts "Account #{account.code} total "
				BankUtils.check account.pos_value, account.value
				puts "_____________________________________/"
			end
			get_grand_total
		end

		def get_grand_total
			@reader.go_to 2
			total = SingleField.new("NET ASSETS",[Setup::Type::AMOUNT])
			total.execute @reader
			acumulated = 0
			accounts.map{|p| acumulated += p.pos_value}
			puts "\nGRAND TOTAL: "
			BankUtils.check acumulated, to_number(total.results[0].result)
			puts "_____________________________________/"
			@total_out = to_number(total.results[0].result)
		end

		def recognize_accounts
			new_accounts = HSBC::Accounts.new(@reader).analyze
			unless @reader.find_text(/PORTFOLIO\ \d{3}[A-Z]\d{7}\ /i)
				code = @reader.find_text(/^\d{1,2} [A-Z]{4,10} 20\d{2} Account: \d{3}[A-Z]\d{7} USD \(E\&OE\)/).split(' ')[4]
				only_acc = AccountHSBC.new(code,nil)
				only_acc.value = 0.0 
				new_accounts.map{|a| only_acc.value += a.value}
				new_accounts = [only_acc]
				while Field.new("Top 5 performers since inception").execute @reader
					#puts @reader.page
				end
			end
			return new_accounts
		end

		def liquidity_for account
			new_positions = []
			current = fx = nil
			new_positions += current if (current = HSBC::CurrentAccount.new(@reader).analyze(account.title))
			new_positions += fx if (fx = HSBC::FX.new(@reader).analyze(account.title))
			return new_positions
		end

		def fixed_income_for account
			return HSBC::FixedIncome.new(@reader).analyze(account.title)
		end

		def hedge_funds_for account
			return HSBC::MutualFunds.new(@reader).analyze(account.title)
		end

		def equity_for account
			return HSBC::Stocks.new(@reader).analyze(account.title)
		end

		def others_for account
			return HSBC::Others.new(@reader).analyze(account.title)
		end

		def real_estate_for account
			return HSBC::RealEstate.new(@reader).analyze(account.title)
		end

		def private_equity_for account
			return HSBC::PrivateEquity.new(@reader).analyze(account.title)
		end
end