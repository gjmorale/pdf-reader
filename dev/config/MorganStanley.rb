class MorganStanley < Bank

	HEADER_ORIENTATION = 6

	module Custom
		ACC_CODE = -1
		PAGE = -2
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d)\.\d{2}%'
		when Setup::Type::AMOUNT
			'([$]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}|(?:\342\200\224))'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,+?[0-9]{3})*\)?|(?:\342\200\224))\s*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*'
		when Setup::Type::DATE
			'\(?\d{2}\/\d{2}\/\d{2}\)?'
		when Custom::ACC_CODE
			'[0-9]{3}\-[0-9]{6}\-[0-9]{3}'
		when Custom::PAGE
			'[1-9][0-9]*'
		end
	end

	def run
		file = Dir["in/11 Nov*"][0]
		analyse_position file
		puts "*****************************************"
		file = Dir["in/MS*"][0]
		analyse_position file
		puts "*****************************************"
	end

	private  

		def analyse_position file
			puts "#{file}"
			@reader = Reader.new(file)
			check_multiple_accounts
			while Field.new("Account Summary").execute @reader
				recognize_account
				Field.new("This page intentionally left blank").execute @reader
			end
=begin
			@accounts.reverse_each do |account|
				puts "\nSEARCHING LIQUIDITY FOR #{account} in #{@reader.page}".green_bg
				liquidity_for(account)
				puts "\nSEARCHING FIXED INCOME FOR #{account}"
				fixed_income_for(account)
				puts "\nSEARCHING EQUITIES FOR #{account}"
				equity_for(account)
			end
			@positions.each{|p| puts "#{p}"}
=end
		end

		def recognize_account
			total_field = SingleField.new("TOTAL ENDING VALUE", [Setup::Type::AMOUNT, Setup::Type::AMOUNT])
			total_field.execute @reader
			puts "#{to_number(total_field.results[0].result)} #{@reader.page}" 
		end

		def check_multiple_accounts
			original_page = @reader.page
			consolidated = Field.new("Consolidated Summary")
			if consolidated.execute @reader
				@accounts = accounts_table
			else
				@accounts = []
				@accounts << single_account
			end
		end

		def accounts_table
			table_end = Field.new("Total Business Accounts")
			search = Field.new("OVERVIEW OF YOUR ACCOUNT")
			offset = Field.new("Business Accounts")
			headers = []
			headers << HeaderField.new("Account Number", headers.size, Custom::ACC_CODE, false)
			headers << HeaderField.new("Beginning Value", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new(["Funds","Credited/(Debited)"], headers.size, to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Security/Currency","Transfers","Rcvd/(Dlvd)"], headers.size, Setup::Type::INTEGER, false, 6)
			headers << HeaderField.new("Change in Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new("Ending Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Income/Dist","This Period/YTD"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 4)
			headers << HeaderField.new(["YTD Realized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new("Page", headers.size, Custom::PAGE, true, 4)
			new_accounts = []
			present = get_table(headers, offset, table_end, search) do |table|
				table.print_results
				table.rows.each.with_index do |row, i|
					new_accounts << AccountMS.new(parse_account(table.headers[0].results[i].result), 
						to_number(table.headers[5].results[i].result))
				end
			end
			if present
				new_accounts.map{|p| puts "#{p}"}
				total = SingleField.new("Total Business Accounts",to_arr(Setup::Type::INTEGER, 3))
				total.execute @reader
				total.print_results
=begin
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[0])
				new_positions.map{|p| @positions << p }
=end
				return new_accounts
			end
		end

		def single_account
			@reader.go_to(3)
			code = SingleField.new("Account Summary", [Custom::ACC_CODE], 4)
			code.execute @reader
			code.print_results

		end


		def get_table(headers, offset, table_end, search, skips = nil)
			original_page = @reader.page
			bottom = nil
			present = true
			while bottom.nil?
				unless search.execute @reader
					present = false
					break
				end
				bottom = @reader.read_next_field(table_end) ? table_end : nil
				table = Table.new(headers, bottom, offset, skips)
				table.execute @reader
				yield table
				@reader.go_to(@reader.page + 1) if bottom.nil?
			end
			if present
				return true
			else
				puts " - No Equity for this account"
				@reader.go_to original_page
				return nil
			end
		end

		def to_number str
			str = str.to_s.strip.delete('$').delete(',').to_f
		end

		def parse_account str
			if str.is_a? Multiline
				str.strings.each do |s|
					return s if s.match(get_regex(Custom::ACC_CODE, false))
				end
			else
				return str
			end
		end

end