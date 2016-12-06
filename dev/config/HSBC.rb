class HSBC < Bank

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
			#raise NoMethodError, "Float not implementd yet"
			'.*'
		end
	end

	def run 
		@positions = []
		@accounts = []
		analyse_position
	end

	private

		def analyse_position
			file = Dir["in/*"][1]
			@reader = Reader.new(file)
			recognize_accounts
			@accounts.reverse_each do |account|
				#puts "\nSEARCHING LIQUIDITY FOR #{account} in #{@reader.page}".green_bg
				#liquidity_for(account)
				puts "\nSEARCHING FIXED INCOME FOR #{account}".green_bg
				fixed_income_for(account)
				puts "\nSEARCHING EQUITIES FOR #{account}".green_bg
				equity_for(account)
			end
		end

		def recognize_accounts
			portfolios = SingleField.new("Portfolios consolidated for this account: ",[Setup::Type::INTEGER])
			portfolios.execute @reader
			portfolios.print_results
			headers = []
			headers << (portfolio = HeaderField.new("Portfolio", headers.size, Setup::Type::LABEL))
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << (values = HeaderField.new("Market value in USD", headers.size, Setup::Type::AMOUNT, true))
			bottom = Field.new("TOTAL PORTFOLIOS IN CREDIT")
			table = Table.new(headers, bottom)
			table.execute @reader
			portfolio.results.each.with_index do |result, i|
				account_data = parse_account(result.result)
				account = AccountHSBC.new(account_data[0], account_data[1])
				account.value = values.results[i].result.to_s.delete(',').to_f
				@accounts << account
			end
			net_assets = SingleField.new("NET ASSETS",[Setup::Type::AMOUNT])
			net_assets.execute @reader
			total = 0
			@accounts.each do |account|
				total += account.value
			end
			puts "INTEGRITY_ACTION: #{total.round(2)} vs #{net_assets.results[0].result.to_s}"
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
			search = Field.new("Liquidity and Money Market - Portfolio #{account.code} - #{account.name}")
			search.execute @reader
			offset = Field.new("Current Accounts")
			bottom = Field.new("Total")
			headers = []
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Qty. / Balance", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
			headers << HeaderField.new(["% Acc.","% Liq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
			table = Table.new(headers, bottom, offset)
			table.execute @reader
			#table.print_results
			total = SingleField.new("Total",[Setup::Type::AMOUNT])
			total.execute @reader
			#total.print_results
			global = SingleField.new("Total Liquidity and Money Market",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
			global.execute @reader
			#global.print_results
		end

		def fixed_income_for account
			original_page = @reader.page
			table_end = Field.new("Total Fixed Income")
			page_end = Field.new("31 OCTOBER 2016")
			bottom = nil
			search = Field.new("Fixed Income - Portfolio #{account.code} - #{account.name}")
			offset = Field.new("Fixed Income Mutual Funds")
			present = true
			while bottom != table_end
				@reader.go_to(@reader.page + 1) unless bottom.nil?
				search.execute @reader
				if search.position.nil?
					present = false
					break
				end
				bottom = @reader.read_next_field(table_end) ? table_end : page_end
				headers = []
				headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
				headers << HeaderField.new("Qty. / Nominal", headers.size, Setup::Type::AMOUNT)
				headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
				headers << HeaderField.new("Region", headers.size, Setup::Type::PERCENTAGE, false, 4)
				headers << HeaderField.new(["Rating","Coupon"], headers.size, Setup::Type::PERCENTAGE, false, 4)
				headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
				headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
				headers << HeaderField.new(["Market price","Date"], headers.size, [Custom::LONG_AMOUNT, Setup::Type::DATE], false, 4)
				headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
				headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, to_arr(Setup::Type::AMOUNT, 2), false, 4)
				headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
				headers << HeaderField.new(["% Acc.","% FI"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
				table = Table.new(headers, bottom, offset)
				table.execute @reader
				table.rows.each.with_index do |row, i|
					@positions << Position.new(headers[2].results[i].result, 
						to_number(headers[1].results[i].result), 
						to_number(to_type(headers[7].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(headers[9].results[i].result), 
						Setup::AccType::FIXED_INCOME)
				end
				#table.print_results
			end
			if present
				@positions.map{|p| puts "#{p}"}
				total = SingleField.new("Total Fixed Income",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				total.print_results
			else
				puts " - No Fixed Income for this account"
				@reader.go_to original_page
			end
		end

		def equity_for account
			original_page = @reader.page
			table_end = Field.new("Total Equity")
			page_end = Field.new("31 OCTOBER 2016")
			bottom = nil
			search = Field.new("Equities - Portfolio #{account.code} - #{account.name}")
			offset = Field.new("Equity Mutual Funds")
			present = true
			new_positions = []
			while bottom != table_end
				@reader.go_to(@reader.page + 1) unless bottom.nil?
				search.execute @reader
				if search.position.nil?
					present = false
					break
				end
				bottom = @reader.read_next_field(table_end) ? table_end : page_end
				headers = []
				headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
				headers << HeaderField.new("Qty.", headers.size, Setup::Type::AMOUNT)
				headers << HeaderField.new(["Description","ISIN / Reference"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
				headers << HeaderField.new("Sector", headers.size, Setup::Type::PERCENTAGE, false, 4)
				headers << HeaderField.new(["YTM / Duration","Maturity"], headers.size, Setup::Type::PERCENTAGE, false, 4)
				headers << HeaderField.new(["Avg. price","Last buy/trsf. date"], headers.size, Custom::LONG_AMOUNT, false, 4)
				headers << HeaderField.new(["Market price","Date"], headers.size, [Setup::Type::AMOUNT, Setup::Type::DATE], false, 4)
				headers << HeaderField.new(["Mkt. value","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::FLOAT], false, 4)
				headers << HeaderField.new(["Mkt. value (USD)","incl. accr. int."], headers.size, [Setup::Type::AMOUNT, Setup::Type::FLOAT], false, 4)
				headers << HeaderField.new(["Unr. P&L","incl. FX"], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
				headers << HeaderField.new(["% Acc.","% Eq."], headers.size, to_arr(Setup::Type::PERCENTAGE, 2), false, 4)
				skips = ["Developed Europe ex UK","North America (US, CA)","Japa"]
				table = Table.new(headers, bottom, offset, skips)
				table.execute @reader
				table.rows.each.with_index do |row, i|
					new_positions << Position.new(headers[2].results[i].result, 
						to_number(headers[1].results[i].result), 
						to_number(to_type(headers[6].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(headers[8].results[i].result), 
						Setup::AccType::EQUITY_MUTUAL_FUND)
				end
				#table.print_results
			end
			if present
				new_positions.map{|p| puts "#{p}"}
				total = SingleField.new("Total Equity",[Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
				total.execute @reader
				total.print_results
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				puts "CHECK #{acumulated} - #{to_number(total.results[0])}"
			else
				puts " - No Equity for this account"
				@reader.go_to original_page
			end
		end

		def get_table(headers, offset, table_end, page_end, search, skips)
			original_page = @reader.page
			bottom = nil
			present = true
			new_positions = []
			while bottom != table_end
				@reader.go_to(@reader.page + 1) unless bottom.nil?
				search.execute @reader
				if search.position.nil?
					present = false
					break
				end
				bottom = @reader.read_next_field(table_end) ? table_end : page_end
				table = Table.new(headers, bottom, offset, skips)
				table.execute @reader
				table.rows.each.with_index do |row, i|
					new_positions << Position.new(headers[2].results[i].result, 
						to_number(headers[1].results[i].result), 
						to_number(to_type(headers[6].results[i].result, Custom::LONG_AMOUNT)), 
						to_number(headers[8].results[i].result))
				end
				#table.print_results
			end
			if present
				return new_positions
			else
				puts " - No Equity for this account"
				@reader.go_to original_page
				return nil
			end
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

		def to_number str
			str = str.to_s.strip.delete(',').to_f
		end
end