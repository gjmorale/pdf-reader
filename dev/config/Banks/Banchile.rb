class BC < Bank
	DIR = "BC"
	LEGACY = "Banchile"
	TABLE_OFFSET = 40
	VERTICAL_SEARCH_RANGE = 5
	HORIZONTAL_SEARCH_RANGE = 5
end

module BC1
end
module BC2
end

require File.dirname(__FILE__) + '/BC/Account.rb'
require File.dirname(__FILE__) + '/BC/AssetTable.rb'
if File.exist? File.dirname(__FILE__) + '/BC/TransactionTable.rb'
	require File.dirname(__FILE__) + '/BC/TransactionTable.rb' 
end

BC.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		FIN_RUT = 	-1
		CUSTODIA = 	-2
		INSTRUMENT= -3
		BLANK = 	-4
		FACTURA = 	-5
		FLOAT2 = 	-6
		FLOAT4 = 	-7
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'((\$|USD)?-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{1,4})?|--)'
		when Setup::Type::INTEGER
			'([1-9]\d{0,2}(?:\.?[0-9]{3})*\)?|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DOLAR|PESO|DOOBS){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*[a-zA-Z].*'
		when Setup::Type::DATE
			'\d{2}\/\d{2}\/\d{4}'
		when Setup::Type::FLOAT
			'-?(?:(?:[1-9]\d{0,2}(?:\.\d{3})*|0)(,(?:\d{2}){1,2})?|,(?:\d{2}){1,2})'
		when Custom::FIN_RUT
			'\d{3}-[0-9kK]'
		when Custom::CUSTODIA
			'(SI|SÍ|--)'
		when Custom::INSTRUMENT
			'(Acciones|Cuota FI)'
		when Custom::BLANK
			'.*'
		when Custom::FACTURA
			'(F:\d{6,8}|--)'
		when Custom::FLOAT2
			'-?(?:[1-9]\d{0,2}(?:\.\d{3})*|0)?(,(?:\d{2}))'
		when Custom::FLOAT4
			'-?(?:[1-9]\d{0,2}(?:\.\d{3})*|0)?(,(?:\d{4}))'
		end
	end

	private  

		def set_date value
			day, month, year = value[value.rindex(' ')+1..-1].split('/')
			@date_out = "#{day}-#{month}-#{year}"
			puts @date_out
		end


		def analyse_position file
			@reader = Reader.new(file)
			set_date @reader.find_text(/Período.*: .*\d{2}\/\d{2}\/\d{4} (al|-) \d{2}\/\d{2}\/\d{4}/i)
			account_field = SingleField.new("Cta: ", [Setup::Type::INTEGER], 3, Setup::Align::LEFT)

			if account_field.execute @reader
				puts "format 1".light_blue
				Setup::Read.vertical_search_range = 100
				account = BC::Account.new(account_field.results[0].result)
				@accounts = [account]
				analyse_position_1 @accounts.first
			else
				puts "format 2".light_blue
				Setup::Read.vertical_search_range = 5
				@accounts = []
				while Field.new("Período del Estado de Cuenta:").execute @reader
					account_field_2 = SingleField.new("Subcuenta:", [Setup::Type::INTEGER], 3, Setup::Align::LEFT)
					account_field_2.execute @reader
					account = BC::Account.new(account_field_2.results[0].result)
					analyse_position_2 account
					@accounts << account
				end
				acumulated = 0.0
				@accounts.map{|p| acumulated += p.pos_value}
				puts "\nGRAND TOTAL: "
				BankUtils.check acumulated, nil
				puts "_____________________________________/"
			end

			if @accounts.nil? or @accounts.empty?
				puts "Unknown format".red
				@accounts = []
			end

			return
		end

		def analyse_position_1 account
			clp = SingleField.new("(valorizado en CLP)$", BankUtils.to_arr(Setup::Type::AMOUNT,5), 3, Setup::Align::LEFT)
			usd = SingleField.new("USDUSD",BankUtils.to_arr(Setup::Type::AMOUNT,5), 3, Setup::Align::LEFT)
			if clp.execute @reader and clp.results[3].result != Result::NOT_FOUND
				if usd.execute @reader and usd.results[3].result != Result::NOT_FOUND
					@clp_value = BankUtils.to_number clp.results[3].result, true
					@usd_value = BankUtils.to_number usd.results[3].result, true
					AssetTable.set_currs(usd: @clp_value/@usd_value)
				else
					puts "NO USD VALUE DETECTED".red
				end
			end

			total = SingleField.new("Total Patrimonio Nacional", BankUtils.to_arr(Setup::Type::AMOUNT, 5), 3, Setup::Align::LEFT)
			total.execute @reader
			@total_out = BankUtils.to_number total.results[3].result, true
			account.value = @total_out
			puts "\nACC: #{account.code} - $#{account.value}"

			account.add_pos analyse_mutual_funds BC1
			account.add_mov analyse_mutual_funds_mov BC1
			account.add_pos analyse_investment_funds BC1
			account.add_mov analyse_investment_funds_mov BC1
			account.add_pos analyse_stocks BC1
			account.add_mov analyse_stocks_mov BC1

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"

		end

		def analyse_position_2 account

			total = SingleField.new("Total Activos", BankUtils.to_arr(Setup::Type::AMOUNT, 2), 3, Setup::Align::LEFT)
			total.execute @reader
			#total.print_results
			total_activos = BankUtils.to_number total.results[1].result.inspect, true
			total = SingleField.new("Total Pasivos", BankUtils.to_arr(Setup::Type::AMOUNT, 2), 3, Setup::Align::LEFT)
			total.execute @reader
			#total.print_results
			total_pasivos = BankUtils.to_number total.results[1].result.inspect, true
			@total_out = total_activos - total_pasivos
			account.value = @total_out
			puts "\nACC: #{account.code} - $#{account.value}"

			account.add_pos Position.new("Total Pasivos", 1.0, -total_pasivos, -total_pasivos)

			@reader.next_page

			account.add_pos analyse_mutual_funds_2 BC2
			account.add_pos analyse_investment_funds_2 BC2
			account.add_pos analyse_stocks_2 BC2
			account.add_pos analyse_fixed_income_2 BC2
			account.add_mov analyse_transactions_2 BC2

			@reader.next_page

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
		end

		### FORMAT 1 ###

		def analyse_mutual_funds factory
			new_pos = []
			pos = nil
			new_pos += pos if(pos = factory::MutualFundsCLP.new(@reader).analyze)
			new_pos += pos if(pos = factory::MutualFundsUSD.new(@reader).analyze)
			new_pos
		end

		def analyse_mutual_funds_mov factory
			new_mov = []
			mov = nil
			new_mov += mov if(mov = factory::MutualFundsMovCLP.new(@reader).analyze)
			new_mov
		end

		def analyse_investment_funds factory
			new_pos = []
			pos = nil
			new_pos += pos if(pos = factory::InvestmentFundsCLP.new(@reader).analyze)
			new_pos += pos if(pos = factory::InvestmentFundsUSD.new(@reader).analyze)
			new_pos
		end

		def analyse_investment_funds_mov factory
			new_mov = []
			mov = nil
			new_mov += mov if(mov = factory::InvestmentFundsMovCLP.new(@reader).analyze)
			new_mov
		end

		def analyse_stocks factory
			new_pos = []
			pos = nil
			new_pos += pos if(pos = factory::StocksCLP.new(@reader).analyze)
			new_pos
		end

		def analyse_stocks_mov factory
			new_mov = []
			mov = nil
			new_mov += mov if(mov = factory::StocksMovCLP.new(@reader).analyze)
			new_mov.map{|m| m.id_sec1 = @accounts.first.code}
			new_mov
		end

		### FORMAT 2 ###

		def analyse_mutual_funds_2 factory
			new_pos = factory::MutualFunds.new(@reader).analyze
			@reader.go_to(@reader.page, 0)
			new_pos
		end

		def analyse_investment_funds_2 factory
			factory::InvestmentFunds.new(@reader).analyze
		end

		def analyse_fixed_income_2 factory
			factory::FixedIncome.new(@reader).analyze
		end

		def analyse_fixed_income_2 factory
			new_pos = []
			pos = nil
			new_pos += pos if pos = factory::FixedIncome.new(@reader).analyze
			new_pos += pos if pos = factory::FixedIncomeAlt.new(@reader).analyze
			return new_pos
		end

		def analyse_stocks_2 factory
			factory::Stocks.new(@reader).analyze
		end

		def analyse_transactions_2 factory
			factory::TransactionTable.new(@reader).analyze
		end
end
