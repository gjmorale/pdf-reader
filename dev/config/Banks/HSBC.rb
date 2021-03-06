require_relative "Bank.rb"
class HSBC < Bank
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
			Bank::MONTHS.each do |m|
				if value =~ m[1]
					month = m[0]
					break
				end
			end
			day = value[0..value.index(' ')-1]
			year = value[value.rindex(' ')+1..-1].strip
			@date_out = "#{day}-#{month}-#{year}"
		end

		def analyse_position file
			@reader = Reader.new(file)
			set_date @reader.find_text(/^\d{1,2} [A-Z]{4,10} 20\d{2}/)
			puts "\nSEARCHING ACCOUNTS"
			@accounts, grand_total = recognize_accounts
			@total_out = grand_total
			@accounts.reverse_each do |account|
				puts "\nSEARCHING LIQUIDITY FOR #{account}"
				account.add_pos liquidity_for(account)
				puts "\nSEARCHING FIXED INCOME FOR #{account}"
				account.add_pos fixed_income_for(account)
				puts "\nSEARCHING EQUITIES FOR #{account}"
				account.add_pos equity_for(account)
				puts "\nSEARCHING HEDGE FUNDS FOR #{account}"
				account.add_pos hedge_funds_for(account)
				puts "\nSEARCHING PRIVATE EQUITY FOR #{account}"
				account.add_pos private_equity_for(account)
				puts "\nSEARCHING REAL ESTATE FOR #{account}"
				account.add_pos real_estate_for(account)
				puts "\nSEARCHING OTHERS FOR #{account}"
				account.add_pos others_for(account)
				puts "\nCHECKING NET ASSETS FOR #{account}"
				check account.pos_value, account.value
			end
			puts "\nCHECKING TOTAL NET ASSETS"
			acumulated = 0
			@accounts.map{|a| acumulated += a.pos_value}
			check acumulated, grand_total
		end

		def recognize_accounts
			portfolios = SingleField.new("Portfolios consolidated for this account: ",[Setup::Type::INTEGER])
			portfolios.execute @reader
			#portfolios.print_results
			headers = []
			headers << (portfolio = HeaderField.new("Portfolio", headers.size, Setup::Type::LABEL))
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << (values = HeaderField.new("Market value in USD", headers.size, Setup::Type::AMOUNT, true))
			bottom = Field.new("TOTAL PORTFOLIOS IN CREDIT")
			table = Table.new(headers, bottom)
			table.execute @reader
			table.print_results
			new_accounts = []
			portfolio.results.each.with_index do |result, i|
				account_data = parse_account(result.result)
				account = AccountHSBC.new(account_data[0], account_data[1])
				account.value = values.results[i].result.to_s.delete(',').to_f
				new_accounts << account
			end
			net_assets = SingleField.new("NET ASSETS",[Setup::Type::AMOUNT])
			net_assets.execute @reader
			total = 0
			new_accounts.each do |account|
				total += account.value
			end
			grand_total = to_number(net_assets.results[0].result)
			check total.round(2), grand_total
			unless Field.new("At a glance - Portfolio ").execute @reader
				code = @reader.find_text(/^\d{1,2} [A-Z]{4,10} 20\d{2} Account: \d{3}[A-Z]\d{7} USD \(E\&OE\)/).split(' ')[4]
				only_acc = AccountHSBC.new(code,nil)
				only_acc.value = 0.0 
				new_accounts.map{|a| only_acc.value += a.value}
				new_accounts = [only_acc]
				puts only_acc.title
				while Field.new("Top 5 performers since inception").execute @reader
					#puts @reader.page
				end
			end
			return new_accounts, grand_total
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

		def fixed_income_for account
			table_end = Field.new("Total Fixed Income")
			page_end = Field.new(" Account: ")
			search = Field.new("Fixed Income#{account.title}")
			offset = [Field.new("Fixed Income Mutual Funds"), Field.new("Bonds")]
			headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Nominal", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 5)
			headers << HeaderField.new("Region", headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Rating","Coupon"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Custom::LONG_AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% FI"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			new_positions = []
			present = get_table(headers, offset, table_end, page_end, search) do |table|
				table.rows.each.with_index do |row, i|
					titles = parse_position table.headers[2].results[i].result, 'ISIN'
					new_positions << Position.new(titles[0], 
						to_number(table.headers[1].results[i].result), 
						to_number(to_type(table.headers[7].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(table.headers[9].results[i].result),
						titles[1])
				end
			end
			if present
				#new_positions.map{|p| puts "FIXED #{p}"}
				total = SingleField.new("Total Fixed Income",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				#total.print_results
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0].result)
				return new_positions
			else
				puts " - No Fixed Income for this account"
			end
		end

		def hedge_funds_for account
			table_end = Field.new("Total Hedge Funds")
			page_end = Field.new(" Account: ")
			search = Field.new("Hedge Funds#{account.title}")
			offset = Field.new("Hedge Funds")
			headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new("Maturity", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Custom::LONG_AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% HF."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			new_positions = []
			present = get_table(headers, offset, table_end, page_end, search) do |table|
				table.rows.each.with_index do |row, i|
					titles = parse_position table.headers[2].results[i].result, 'ISIN'
					new_positions << Position.new(titles[0], 
						to_number(table.headers[1].results[i].result), 
						to_number(to_type(table.headers[5].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(table.headers[7].results[i].result),
						titles[1])
				end
			end
			if present
				total = SingleField.new("Total Hedge Funds",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				#total.print_results
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0].result)
				return new_positions
			else
				puts " - No Hedge Funds for this account"
			end
		end

		def equity_for account
			table_end = Field.new("Total Equity")
			page_end = Field.new(" Account: ")
			search = Field.new("Equities#{account.title}")
			offset = Field.new("Equity Mutual Funds")
			headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty.", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new("Sector", headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Setup::Type::AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::FLOAT], false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Eq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			skips = ["Developed Europe ex UK","North America (US, CA)","Japan"].map{|s| Regexp.escape(s)}
			new_positions = []
			present = get_table(headers, offset, table_end, page_end, search, skips) do |table|
				table.rows.each.with_index do |row, i|
					titles = parse_position table.headers[2].results[i].result, 'ISIN'
					new_positions << Position.new(titles[0], 
						to_number(table.headers[1].results[i].result), 
						to_number(to_type(table.headers[6].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(table.headers[8].results[i].result),
						titles[1])
				end
			end
			if present
				#new_positions.map{|p| puts "EQUITY #{p}"}
				total = SingleField.new("Total Equity",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				#total.print_results
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0].result)
				return new_positions
			else
				puts " - No Equity for this account"
			end
		end

		def others_for account
			table_end = Field.new("Total Others")
			page_end = Field.new(" Account: ")
			search = Field.new("Others#{account.title}")
			offset = Field.new("Other Mutual Funds")
			headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
			headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
			headers << HeaderField.new(["Market price","Date"], headers.size, [Setup::Type::AMOUNT, Setup::Type::DATE], false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::AMOUNT], false, 4)
			headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Others."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			new_positions = []
			present = get_table(headers, offset, table_end, page_end, search) do |table|
				table.rows.each.with_index do |row, i|
					titles = parse_position table.headers[2].results[i].result, 'ISIN'
					new_positions << Position.new(titles[0], 
						to_number(table.headers[1].results[i].result), 
						to_number(to_type(table.headers[5].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(table.headers[7].results[i].result),
						titles[1])
				end
			end
			if present
				total = SingleField.new("Total Others",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0].result)
				return new_positions
			else
				puts " - No Others for this account"
			end
		end

		def get_table(headers, offset, table_end, page_end, search, skips = nil, verbose = false)
			@reader.stash
			bottom = nil
			exit = false
			present = true
			while not exit
				@reader.go_to(@reader.page + 1) unless bottom.nil?
				if search
				search.execute @reader
					if search.position.nil?
						present = false
						break
					end
				end
				cloned_table_end = clone_it table_end
				cloned_page_end = clone_it page_end
				cloned_headers = clone_it headers
				cloned_offset = clone_it offset
				if @reader.read_next_field(cloned_table_end)
					bottom = cloned_table_end
					exit = true
				else
				 	bottom = cloned_page_end
				end
				table = Table.new(cloned_headers, bottom, cloned_offset, skips)
				if table.execute @reader
					table.print_results if verbose
					yield table
				else
					if not exit
						@reader.pop
						return false
					end
				end
				#table.print_results
=begin  FROM MASTER
				bottom = @reader.read_next_field(table_end) ? table_end : page_end
				table = Table.new(headers, bottom, offset, skips)
				if table.execute @reader
					table.rows.each.with_index do |row, i|
						results = table.headers.map {|h| h.results[-i-1].result}
						yield results
					end
				end
=end
			end
			if present
				return true
			else
				@reader.pop
				return nil
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

		def to_type str, type
			if str.is_a? Multiline
				str.strings.each do |s|
					if s.match(regex(type)) 
						return s
					end
				end
			else
				return str
			end
		end
end