require_relative "Bank.rb"
class MorganStanley < Bank
	DIR = "MS"
end

Dir[File.dirname(__FILE__) + '/MS/*.rb'].each {|file| require_relative file }

MorganStanley.class_eval do

	def dir
		self.class::DIR
	end

	HEADER_ORIENTATION = 6
	HORIZONTAL_SEARCH_RANGE = 10

	module Custom
		ACC_CODE = 		-1
		PAGE = 			-2
		DATE_OR_TOTAL = -3
		AMOUNT_W_TERM = -4
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'([$]?\(?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{1,3}\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,+?[0-9]{1,3})*\)?|(?:\342\200\224)){1}\s*'
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
			'[0-9]{3}\-[0-9]{6}\-[0-9]{3}'
		when Custom::PAGE
			'[1-9][0-9]*'
		when Custom::DATE_OR_TOTAL
			'(\d{1,2}\/\d{1,2}\/\d{2}|Total|(?:\342\200\224)){1}\s*'
		when Custom::AMOUNT_W_TERM
			'([$]?\(?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}\)?(\s*(LT|ST))|(?:\342\200\224)){1}\s*'
		end
	end

	private  

		def analyse_position file
			puts "ANALYSING #{file}"
			@reader = Reader.new(file)
			check_multiple_accounts
			last_acc = ""
			code_s = ""
			@accounts.reverse_each do |account|
				Field.new("Account Summary").execute @reader
				Field.new("Account Detail").execute @reader

=begin
				while code_s == last_acc
					start = SingleField.new("Account Summary", [Custom::ACC_CODE], 4)
					start.execute @reader
					code_s = parse_account start.results[0].result
				end
				last_acc = code_s
=end
				puts "\nACC: #{account.code} - #{account.value}"
				account.add_pos analyse_cash
				account.add_pos analyse_stock
				account.add_pos analyse_etfs
				account.add_pos analyse_fixed_income
				account.add_pos analyse_government_securities
				account.add_pos analyse_mutual_funds
				account.add_pos analyse_alternative_investments

				print "Account ... "
				check account.pos_value, account.value
			end
			get_grand_total
		end

		def get_grand_total
			@reader.go_to 1
			total = SingleField.new("$", [Setup::Type::AMOUNT])
			total.execute @reader
			acumulated = 0
			accounts.map{|p| acumulated += p.pos_value}
			print "GRAND TOTAL: "
			check acumulated, to_number(total.results[0].result)
		end

		def analyse_cash
			print "Proccesing cash ... "
			table_end = [Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM),
				Field.new("BANK DEPOSITS")]
			search = Field.new("CASH, BANK DEPOSIT PROGRAM AND MONEY MARKET FUNDS")
			headers = []
			headers << HeaderField.new("Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["7-Day","Current Yield %"], headers.size, Setup::Type::FLOAT, false, 4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("APY %", headers.size, Setup::Type::FLOAT, false)
			new_positions = []
			present = get_table(headers, nil, table_end, search) do |table|
				table.rows.each.with_index do |row, i|
					new_positions << Position.new(table.headers[0].results[i].result, 
						to_number(table.headers[1].results[i].result), 
						1.0, 
						to_number(table.headers[1].results[i].result))
				end
			end
			if present
				variant = ""
				variant_cue = SingleField.new("NET UNSETTLED PURCHASES/SALES", [Setup::Type::AMOUNT], 6, Setup::Align::LEFT)
				if @reader.read_next_field(variant_cue)
					variant_cue.execute @reader
					variant = " (PROJECTED SETTLED BALANCE)"
					new_positions << Position.new("NET UNSETTLED PURCHASES/SALES", 
						to_number(variant_cue.results[0].result), 
						1.0, 
						to_number(variant_cue.results[0].result))
				end
				total = SingleField.new("CASH, BDP, AND MMFs#{variant}",[Setup::Type::PERCENTAGE, Setup::Type::AMOUNT, Setup::Type::AMOUNT], 2)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[1].result)
				return new_positions
			else 
				puts "Cash, BDP and MMFs table is missing."
			end
		end

		def analyse_stock
			unless @reader.move_to(Field.new("STOCKS"),2)
				puts "No stock for this account"
				return false
			else
				print "Proccesing stocks ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			quantity = price = value = "0.0"
			title = false
			total = false
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						quantity = results[2]
						value = results[6]
					end
					new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
					if new_title
						if title 
							new_positions << Position.new(title, 
								to_number(quantity), 
								to_number(price), 
								to_number(value))
						end
						title = new_title
						price = results[4]
						quantity = results[2]
						value = results[6]
						total = false
					end
				end
			end
			if title
				new_positions << Position.new(title, 
					to_number(quantity), 
					to_number(price), 
					to_number(value))
			end
			if present
				total = SingleField.new("STOCKS",[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Custom::AMOUNT_W_TERM, 
					Setup::Type::AMOUNT, 
					Setup::Type::PERCENTAGE], 
					6, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[2].result)
				return new_positions
			else 
				puts "STOCKS table is missing."
				return analyse_stock_alternative
			end
		end

		def analyse_stock_alternative
			@reader.go_to(@reader.page)
			unless @reader.move_to(Field.new("STOCKS"),2)
				puts "No stock alternative for this account"
				return false
			else
				print "Proccesing stocks alternative ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			quantity = price = value = "0.0"
			title = false
			total = false
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						quantity = results[1]
						value = results[4]
					end
					new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
					if new_title
						if title 
							new_positions << Position.new(title, 
								to_number(quantity), 
								to_number(price), 
								to_number(value))
						end
						title = new_title
						price = results[2]
						quantity = results[1]
						value = results[4]
						total = false
					end
				end
			end
			if title
				new_positions << Position.new(title, 
					to_number(quantity), 
					to_number(price), 
					to_number(value))
			end
			if present
				total = SingleField.new("STOCKS",[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT,  
					Setup::Type::AMOUNT, 
					Setup::Type::PERCENTAGE], 
					6, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[2].result)
				return new_positions
			else 
				puts "STOCKS alternative table is missing."
			end
		end

		def analyse_mutual_funds
			unless @reader.move_to(Field.new("MUTUAL FUNDS"), 2)
				puts "No mutual funds for this account"
				return false
			else
				print "Proccesing mutual funds ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, true)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Share Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new("Est Ann Income", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			quantity = price = value = "0.0"
			title = false
			total = false
			title_dump = /(Long Term Reinvestments|Short Term Reinvestments|Total Purchases vs Market Value|Net Value Increase\/\(Decrease\))/
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						price = results[4]
						quantity = results[2] 
						value = results[6]
					end
					new_title = "#{results[0]}".gsub(title_dump, "")
					new_title = (new_title.nil? or new_title.empty? or new_title == Result::NOT_FOUND) ? false : new_title
					if new_title
						if title 
							new_positions << Position.new(title, 
								to_number(quantity), 
								to_number(price), 
								to_number(value))
						end
						title = new_title
						price = results[4]
						quantity = results[2] 
						value = results[6]
						total = false
					end
				end
			end
			if title
				new_positions << Position.new(title, 
					to_number(quantity), 
					to_number(price), 
					to_number(value))
			end
			if present
				total = SingleField.new("MUTUAL FUNDS",
					[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Custom::AMOUNT_W_TERM, 
					Setup::Type::AMOUNT, 
					Setup::Type::FLOAT], 
					4, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[2].result)
				return new_positions
			else 
				puts "MUTUAL FUNDS table is missing."
			end
		end

		def analyse_government_securities
			unless @reader.move_to(Field.new("GOVERNMENT SECURITIES"),2)
				puts "No gov. securities for this account"
				return false
			else
				print "Proccesing gov securities ... "
			end

			table_end = Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Custom::DATE_OR_TOTAL, true)
			headers << HeaderField.new("Face Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Unit Cost","Adj Unit Cost"], headers.size, to_arr(Setup::Type::FLOAT, 2), false)
			headers << HeaderField.new("Unit Price", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Orig Total Cost","Adj Total Cost"], headers.size, to_arr(Setup::Type::AMOUNT, 2), false)
			headers << HeaderField.new("Market Value", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Custom::AMOUNT_W_TERM, false,4)
			headers << HeaderField.new(["Est Ann Income","Accrued Interest"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Current","Yield %"], headers.size, Setup::Type::FLOAT, false,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			face_value = price = value = ai = "0.0"
			title = false
			total = false
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					if results[1] == "Total"
						total = true
						face_value = results[2] 
						value = results[6]
						ai = accured_interest(results[8])
					end
					new_title = (results[0].nil? or results[0].empty? or results[0] == Result::NOT_FOUND) ? false : results[0]
					if new_title
						if title 
							titles = parse_position(title)
							new_positions << Position.new(titles[0], 
								to_number(face_value), 
								to_number(price), 
								to_number(value) + to_number(ai),
								titles[1])
						end
						title = new_title
						price = results[4]
						face_value = results[2] 
						value = results[6]
						ai = accured_interest(results[8])
						total = false
					end
				end
			end
			if title
				titles = parse_position(title)
				new_positions << Position.new(titles[0], 
					to_number(face_value), 
					to_number(price), 
					to_number(value) + to_number(ai),
					titles[1])
			end
			if present
				total = SingleField.new("GOVERNMENT SECURITIES",
					[Setup::Type::PERCENTAGE, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Custom::AMOUNT_W_TERM, 
					Setup::Type::AMOUNT], 
					5, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, (to_number(total.results[3].result) + to_number(accured_interest(total.results[5].result)))
				return new_positions
			else 
				puts "GOVERNMENT SECURITIES table is missing."
			end
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
			else
				puts "No alternative investments for this account"
			end
		end

		def analyse_hedge_funds
			title = Field.new('HEDGE FUNDS')
			unless @reader.move_to(title, 2)
				puts "No hedge funds for this account"
				return false
			else
				@reader.skip title
				print "Proccesing hedge funds ... "
			end

			table_end = Field.new("HEDGE FUNDS - SHARES")
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new(["Commitment/","Aggregate Investment"], headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Est Value","+ Redemptions","+ Distributions"], headers.size, Setup::Type::AMOUNT, false, 6)
			headers << HeaderField.new("Total Return", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			value = "0.0"
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					title = results[0] 
					value = results[3]
					new_positions << Position.new(title, 
						0.0, 
						0.0, 
						to_number(value))
				end
			end
			if present
				#TODO: Find possible check using cols 3 and 4
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, 0
				return new_positions
			else 
				puts "HEDGE FUNDS table is missing."
			end
			return false
		end

		def analyse_hedge_fund_shares
			title = Field.new('HEDGE FUNDS - SHARES')
			unless @reader.move_to(title, 2)
				puts "No hedge fund shares for this account"
				return false
			else
				@reader.skip title
				print "Proccesing hedge fund shares ... "
			end

			table_end = Field.new("HEDGE FUNDS - SHARES")
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Setup::Type::DATE, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","NAV"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			price = quantity = value = "0.0"
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					title = results[0]
					price = results[1]
					quantity = results[2] 
					value = results[6]
					new_positions << Position.new(title, 
						to_number(quantity), 
						to_number(price), 
						to_number(value))
				end
			end
			if present
				total = SingleField.new('HEDGE FUNDS - SHARES',
					[Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT,], 
					4, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[1].result)
				return new_positions
			else 
				puts "HEDGE FUNDS - SHARES table is missing."
			end
			return false
		end

		def analyse_managed_futures
			title = Field.new('MANAGED FUTURES')
			unless @reader.move_to(title, 2)
				puts "No managed futures shares for this account"
				return false
			else
				@reader.skip title
				print "Proccesing managed futures shares ... "
			end

			table_end = [Field.new("MANAGED FUTURES"),Field.new("REAL ESTATE"),Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)]
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Trade Date", headers.size, Setup::Type::DATE, false)
			headers << HeaderField.new("Quantity", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Unit Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","NAV"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Total Cost", headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			price = quantity = value = "0.0"
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					title = results[0]
					price = results[1]
					quantity = results[2] 
					value = results[6]
					new_positions << Position.new(title, 
						to_number(quantity), 
						to_number(price), 
						to_number(value))
				end
			end
			if present
				total = SingleField.new('MANAGED FUTURES',
					[Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT,], 
					4, Setup::Align::LEFT)
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				if total.execute @reader
					check acumulated, to_number(total.results[1].result)
				else
					check acumulated, 0					
				end
				return new_positions
			else 
				puts "MANAGED FUTURES table is missing."
			end
			return false
		end

		def analyse_private_equity
			title = Field.new('PRIVATE EQUITY')
			unless @reader.move_to(title, 2)
				puts "No private equity for this account"
				return false
			else
				@reader.skip title
				print "Proccesing private equity ... "
			end

			table_end = Field.new("PRIVATE EQUITY")
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Commitment", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Contributions","to Date"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Remaining","Commitment"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Distributions", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Est Value","+ Distributions"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			quantity = value = "0.0"
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					title = results[0]
					quantity = results[2] 
					value = results[5]
					new_positions << Position.new(title, 
						to_number(quantity), 
						0.0, 
						to_number(value))
				end
			end
			if present
				total = SingleField.new('PRIVATE EQUITY',
					[Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT], 
					4, Setup::Align::LEFT)
				total.execute @reader
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				check acumulated, to_number(total.results[4].result)
				return new_positions
			else 
				puts "PRIVATE EQUITY table is missing."
			end
			return false
		end

		def analyse_real_estate
			title = Field.new('REAL ESTATE')
			unless @reader.move_to(title, 2)
				puts "No real estate for this account"
				return false
			else
				@reader.skip title
				print "Proccesing real estate ... "
			end

			table_end = [Field.new("REAL ESTATE"),Field.new(["Percentage","of Holdings"],4, Setup::Align::BOTTOM)]
			headers = []
			headers << HeaderField.new("Security Description", headers.size, Setup::Type::LABEL, false)
			headers << HeaderField.new("Commitment", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Contributions","to Date"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Remaining","Commitment"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new("Distributions", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new(["Estimated","Value"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Est Value","+ Distributions"], headers.size, Setup::Type::AMOUNT, false, 4)
			headers << HeaderField.new(["Valuation","Date"], headers.size, Setup::Type::DATE, true,4)
			skips = ['.*(?:Asset Class:).*']
			new_positions = []
			quantity = value = "0.0"
			present = get_table(headers, nil, table_end, nil, skips) do |table|
				table.rows.each.with_index do |row, i|
					results = table.headers.map {|h| h.results[-i-1].result}
					title = results[0]
					quantity = results[2] 
					value = results[5]
					new_positions << Position.new(title, 
						to_number(quantity), 
						0.0, 
						to_number(value))
				end
			end
			if present
				total = SingleField.new('REAL ESTATE',
					[Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT, 
					Setup::Type::AMOUNT], 
					4, Setup::Align::LEFT)
				acumulated = 0
				new_positions.map{|p| acumulated += p.value}
				if total.execute @reader
					check acumulated, to_number(total.results[4].result)
				else
					check acumulated, 0
				end
				return new_positions
			else 
				puts "REAL ESTATE table is missing."
			end
			return false
		end

		def parse_position str
			name = str.strings[0]
			str.match /CUSIP/ do |m|
				code = str.strings[m.offset[2]][m.offset[0]..-1]
				return [code,name]
			end
			return [name,nil]
		end

		def accured_interest result
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

		def check_multiple_accounts
			consolidated = Field.new("Consolidated Summary")
			if consolidated.execute @reader
				puts "MULTIPLE"
				@accounts = accounts_table
			else
				puts "SINGLE"
				@accounts = []
				@accounts << single_account
			end
			first_account = Field.new("Account Summary")
			first_account.execute @reader
			@reader.go_to @reader.page
		end

		def accounts_table
			table_end = [Field.new("Total Business Accounts"),Field.new("Total Personal Accounts")]
			search = Field.new("OVERVIEW OF YOUR ACCOUNT")
			offset = [Field.new("Business Accounts"),Field.new("Personal Accounts")]
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
				table.rows.each.with_index do |row, i|
					new_accounts << AccountMS.new(parse_account(table.headers[0].results[i].result), 
						to_number(table.headers[5].results[i].result))
				end
			end
			if present
				#TODO: check total from accounts
				total = SingleField.new("Total Business Accounts",to_arr(Setup::Type::INTEGER, 3))
				total.execute @reader
				return new_accounts
			else 
				puts "Accounts table is missing."
			end
		end

		def single_account
			@reader.go_to(3)
			code = SingleField.new("Account Summary", [Custom::ACC_CODE], 4)
			code.execute @reader
			code.print_results
			code_s = parse_account code.results[0].result
			value = SingleField.new("TOTAL VALUE", [Setup::Type::AMOUNT])
			value.execute @reader
			value_s = to_number(value.results[0].result)
			@reader.go_to(3)
			AccountMS.new(code_s, value_s)
		end


		def get_table(headers, offset, table_end, search, skips = nil, verbose = false)
			original_page = @reader.page
			bottom = nil
			present = false
			while bottom.nil?
				if search and not search.execute @reader
					present = false
					break
				end
				cloned_table_end = clone_it table_end
				cloned_headers = clone_it headers
				cloned_offset = clone_it offset
				bottom = @reader.read_next_field(cloned_table_end)
				bottom = nil unless bottom
				table = Table.new(cloned_headers, bottom, cloned_offset, skips)
				original_offset = @reader.offset
				original_page = @reader.page
				if table.execute @reader and table.width > 1
					present = true
					yield table
					puts "\n"  if verbose
					table.print_results if verbose
				else
					@reader.go_to original_page, original_offset
					return if bottom.nil?
				end 
				@reader.go_to(@reader.page + 1) if bottom.nil?
			end
			if present
				return true
			else
				@reader.go_to original_page
				return nil
			end
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
=begin

TODO: Universal chart method with options for:
 - Total and non total
 - title_dump
 - Handle table precense	
	
=end