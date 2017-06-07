require_relative "Bank.rb"

class MS < Bank
	DIR = "MS"
	LEGACY = "MStanley"
	TABLE_OFFSET = 10
end

Dir[File.dirname(__FILE__) + '/MS/*.rb'].each {|file| require_relative file } 

MS.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	HEADER_ORIENTATION = 6
	HORIZONTAL_SEARCH_RANGE = 10

	module Custom
		ACC_CODE = 		-1
		PAGE = 			-2
		DATE_OR_TOTAL = -3
		AMOUNT_W_TERM = -4
		TOTAL_AMOUNT = -5
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'([$]?\(?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{1,3}\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,?[0-9]{3})*\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'(\(?\d{1,2}\/\d{1,2}\/\d{2}\)?|(?:\342\200\224)){1}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Custom::ACC_CODE
			'[0-9]{3}\-[0-9]{6}\-[0-9]{3}\+?'
		when Custom::PAGE
			'[1-9][0-9]*'
		when Custom::DATE_OR_TOTAL
			'(\d{1,2}\/\d{1,2}\/\d{2}|Total|(?:\342\200\224)){1}\s*'
		when Custom::AMOUNT_W_TERM
			'([$]?\(?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}\)?(\s*(LT|ST))|(?:\342\200\224)){1}\s*'
		when Custom::TOTAL_AMOUNT
			'(Total|Purchases)?([$]?\(?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{1,3}\)?|(?:\342\200\224)){1}\s*'
		end
	end

	private  

		def set_date value
			month = -1
			Bank::MONTHS.each do |m|
				if value =~ m[1]
					month = m[0]
					break
				end
			end
			day = value[value.index('-')+1..value.index(',')-1]
			year = value[value.rindex(' ')+1..-1].strip
			@date_out = "#{day}-#{month}-#{year}"
		end

		def analyse_index file
			@reader = Reader.new(file)
			owner = nil
			set_date @reader.find_text(/[A-Z][a-z]+\ \d{1,2}\-\d{1,2}\,\ 20\d{2}/i)
			header = HeaderField.new("[STATEMENT PACKAGE FOR:|STATEMENT FOR:]",1,Setup::Type::LABEL)
			if header.execute @reader
				xi = header.left < Setup::Table.offset ? 0 : header.left + Setup::Table.offset
				xf = header.right + Setup::Table.offset
				y = header.top
				header.border = TextNode.new(xi, xf, y)
				row = Row.new(y+1, y+12)
				header.set_results(1)
				@reader.get_columns([header],[row])
				owner = header.results[0].result.inspect.strip
				owner = nil if owner.empty?
			end
			return [owner, @date_out]
		end

		def analyse_position file
			@reader = Reader.new(file)
			set_date @reader.find_text(/[A-Z][a-z]+\ \d{1,2}\-\d{1,2}\,\ 20\d{2}/i)
			check_multiple_accounts
			@accounts.each do |account|
				Field.new("Account Summary").execute @reader
				Field.new("Account Detail").execute @reader
				puts "\nACC: #{account.code} - $#{account.value}"
				account.add_pos analyse_cash
				account.add_pos analyse_stock
				account.add_pos analyse_etfs
				account.add_pos analyse_fixed_income
				account.add_pos analyse_government_securities
				account.add_pos analyse_mutual_funds
				account.add_pos analyse_alternative_investments

				puts "Account #{account.code} total "
				BankUtils.check account.pos_value, account.value
				puts "_____________________________________/"
			end
			get_grand_total
		end

		def get_grand_total
			@reader.go_to 1
			total = SingleField.new("$", [Setup::Type::AMOUNT])
			total.execute @reader
			acumulated = 0
			accounts.map{|p| acumulated += p.pos_value}
			puts "\nGRAND TOTAL: "
			BankUtils.check acumulated, to_number(total.results[0].result)
			puts "_____________________________________/"
			@total_out = to_number(total.results[0].result)
		end

		def analyse_cash
			return Cash.new(@reader).analyze
		end

		def analyse_stock
			if(positions = Stocks.new(@reader).analyze)
				return positions
			else
				return StocksAlt.new(@reader).analyze
			end
		end

		def analyse_government_securities
			return GovSecs.new(@reader).analyze
		end

		def analyse_alternative_investments
			if @reader.move_to(Field.new("ALTERNATIVE INVESTMENTS"),2)
				new_positions = []
				pos = nil
				new_positions += pos if(pos = analyse_hedge_funds)
				new_positions += pos if(pos = analyse_hedge_fund_shares)
				new_positions += pos if(pos = analyse_managed_futures)
				new_positions += pos if(pos = analyse_private_equity)
				new_positions += pos if(pos = analyse_real_estate)
				return new_positions
			end
		end

		def analyse_hedge_funds
			return HedgeFunds.new(@reader).analyze
		end

		def analyse_hedge_fund_shares
			return HedgeFundShares.new(@reader).analyze
		end

		def analyse_managed_futures
			return ManagedFutures.new(@reader).analyze
		end

		def analyse_private_equity
			return PrivateEquity.new(@reader).analyze
		end

		def analyse_real_estate
			return RealEstate.new(@reader).analyze
		end

		def analyse_fixed_income
			if(positions = MS::FixedIncome.new(@reader).analyze)
				return positions
			else
				return MS::FixedIncomeAlt.new(@reader).analyze
			end
		end

		def analyse_mutual_funds
			if(positions = MS::MutualFunds.new(@reader).analyze)
				return positions
			else
				return MS::MutualFundsAlt.new(@reader).analyze
			end
		end

		def analyse_etfs
			if(positions = MS::ETFS.new(@reader).analyze)
				return positions
			else
				return MS::ETFSAlt.new(@reader).analyze
			end
		end

		def check_multiple_accounts
			consolidated = Field.new("Consolidated Summary")
			if consolidated.execute @reader
				puts "Multiple accounts detected"
				@accounts = accounts_table
			else
				puts "Single account detected"
				@accounts = []
				@accounts << single_account
			end
			first_account = Field.new("Account Summary")
			first_account.execute @reader
			@reader.go_to @reader.page
		end

		def accounts_table
			accounts = []
			ba = MS::BussinessAccounts.new(@reader).analyze
			pa = MS::PersonalAccounts.new(@reader).analyze
			accounts += ba if ba.is_a? Array
			accounts += pa if pa.is_a? Array
			return accounts
		end

		def single_account
			@reader.go_to(3)
			code = SingleField.new("Account Summary", [Custom::ACC_CODE], 4, Setup::Align::LEFT)
			code.execute @reader
			code_s = code.results[0].result
			if code_s.is_a? Multiline
				code_s.strings.each do |s|
					code_s = s if s.match /[0-9]{3}\-[0-9]{6}\-[0-9]{3}\+?/
				end
			end
			value = SingleField.new("TOTAL VALUE", [Setup::Type::AMOUNT])
			value.execute @reader
			value_s = to_number(value.results[0].result)
			@reader.go_to(3)
			AccountMS.new(code_s, value_s)
		end

end