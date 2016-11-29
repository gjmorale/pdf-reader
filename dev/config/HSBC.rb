class HSBC < Bank

	module Custom
		# Include custom formats specific for the bank here
		# Use negative indexes to avod conflicts
		# E.g: ACCOUNT_CODE = -1
		# And be sure to add a regex in the regex(type) method below
		ACCOUNT_CODE = -1
	end

	attr_accessor :accounts

	TABLE_OFFSET = 15
	CENTER_MASS_LIMIT = 0.0

	def initialize
		#Empty initialize required in very bank sub-class
		#Only to check it's not abstract
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d)\.\d{2}%'
		when Setup::Type::AMOUNT
			'[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}'
		when Setup::Type::INTEGER
			'[+-]?[1-9]\d{0,2}(?:,+?[0-9]{3})*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*'
		when Custom::ACCOUNT_CODE
			'\d{3}[A-Z]\d{7}'
		end
	end

	def setup_files
		@files = Dir["test_cases/*.pdf"]
	end

	def analyse_position
		file = Dir["test_cases/*2016.pdf"][0]
		@reader = Reader.new(file)
		recognize_accounts.each do |field|
			field.execute @reader
			field.print_results unless field.is_a? Action
		end
		@accounts.reverse_each do |account|
			puts "\nSEARCHING LIQUIDITY FOR #{account}"
			(liquidity_for account).each do |field|
				field.execute @reader
				field.print_results unless field.is_a? Action
			end
		end
	end

	def run 
		analyse_position
	end

	def declare_fields
		recognize_accounts
	end

	def recognize_accounts
		fields = []
		fields = [] #First document
		fields << SingleField.new("Portfolios consolidated for this account: ",[Setup::Type::INTEGER])
		headers = []
		headers << (portfolio = HeaderField.new("Portfolio", headers.size, Setup::Type::LABEL))
		headers << (curs = HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true))
		headers << (values = HeaderField.new("Market value in USD", headers.size, Setup::Type::AMOUNT, true))
		bottom = Field.new("TOTAL PORTFOLIOS IN CREDIT")
		fields << Table.new(headers, bottom)
		fields << Action.new(proc {
				bank = Setup.bank
				bank.accounts = []
				portfolio.results.each.with_index do |result, i|
					account_data = bank.parse_account(result.result)
					account = AccountHSBC.new(account_data[0], account_data[1])
					account.value = values.results[i].result.to_s.delete(',').to_f
					@accounts << account
				end
			})
		fields << (net_assets = SingleField.new("NET ASSETS",[Setup::Type::AMOUNT]))
		fields << Action.new(proc {
				total = 0
				Setup.bank.accounts.each do |account|
					total += account.value
				end
				puts "INTEGRITY_ACTION: #{total.round(2)} vs #{net_assets.results[0].result.to_s}"
			})
		return fields
	end

	def parse_account str
		str = str.inspect
		account_data = []
		str.match(get_regex Custom::ACCOUNT_CODE, false) {|m|
			account_data[0] = str[m.offset(0)[0]..m.offset(0)[1]-1]
			account_data[1] = str[m.offset(0)[1]..-1]
		}
		return account_data
	end

	def liquidity_for account
		fields = []
		search = "Liquidity and Money Market - Portfolio #{account.code} - #{account.name}"
		fields << Field.new(search)
		offset = Field.new("Current Accounts")
		bottom = Field.new("Total")
		headers = []
		headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
		headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
		headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, Setup::Type::LABEL, false, 4)
		headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, Setup::Type::AMOUNT, false, 4)
		headers << HeaderField.new(["% Acc.","% Liq."], headers.size, Setup::Type::PERCENTAGE, false, 4)
		fields << Table.new(headers, bottom, offset)
		fields << SingleField.new("Total",[Setup::Type::AMOUNT])
		fields << SingleField.new("Total Liquidity and Money Market",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
	end
end