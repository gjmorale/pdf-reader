require_relative "Bank.rb"

class SEC < Bank
	DIR = "SEC"
	LEGACY = "Security"
	TEXT_EXPAND = 0.0
	TABLE_OFFSET = 20
end

Dir[File.dirname(__FILE__) + '/SEC/*.rb'].each {|file| require_relative file } 

SEC.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		GEST = 		-1
		SI_NO = 	-2
		N_CUENTA = 	-3
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'-?\(?[0-9]{1,3}(?:.?[0-9]{3})*(\,[0-9]{1,4})?\)?'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,?[0-9]{3})*\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}\/\d{2}\/\d{4}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Custom::GEST
			'(N){1}'
		when Custom::SI_NO
			'(NO|SI|SÍ){1}'
		when Custom::N_CUENTA
			'\d{1,2}'
		end
	end

	private  

		def set_date value
			day, month, year = value[value.rindex(' ')..-1].split('-')
			@date_out = "#{day}-#{month}-#{year}"
		end

		def analyse_position file
			@reader = Reader.new(file)
			set_date @reader.find_text(/ al \d{2}-\d{2}-\d{4}/i)
			account_field = SingleField.new("Nombre : ", [Setup::Type::LABEL])
			account_field.execute @reader

			pershing = SingleField.new("Patrimonio en Custodia Pershing",[Setup::Type::AMOUNT,Setup::Type::AMOUNT])
			pershing.execute @reader
			total_pershing = pershing.results[0].result.gsub('.','').to_f

			total = SingleField.new("TOTAL ACTIVOS",[Setup::Type::AMOUNT], 5, Setup::Align::LEFT)
			total.execute @reader
			@total_out = total.results[0].result.gsub('.','').to_f
			
			account = AccountSEC.new(account_field.results[0].result,@total_out-total_pershing)

			usd = SingleField.new("USD:",[Setup::Type::AMOUNT])
			if usd.execute @reader
				@usd_value = usd.results[0].result.gsub('.','').gsub(',','.').to_f
				AssetTable.set_currs(usd: @usd_value)
			end

			while Field.new("SALDO TOTAL").execute @reader
			end
			@reader.next_page
			
			Field.new("DETALLE DE INVERSIONES POR CLASE DE ACTIVOS").execute @reader
			puts "\nACC: #{account.code} - $#{account.value}"
			account.add_pos analyse_mutual_funds
			account.add_pos analyse_investment_funds
			account.add_pos analyse_stocks
			account.add_pos analyse_cash
			account.add_mov analyse_transactions
			@accounts = [account]

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
		end

		def analyse_mutual_funds
			new_positions = pos = []
			new_positions += pos if(pos = SEC::MutualFundsCLP.new(@reader).analyze)
			new_positions += pos if(pos = SEC::MutualFundsUSD.new(@reader).analyze)
			new_positions += pos if(pos = SEC::MutualFundsOthers.new(@reader).analyze)
			return new_positions
		end

		def analyse_investment_funds
			SEC::InvFunds.new(@reader).analyze usd_value
		end

		def analyse_cash
			SEC::Cash.new(@reader).analyze usd_value
		end

		def analyse_stocks
			SEC::Stocks.new(@reader).analyze usd_value
		end

		def analyse_transactions
			SEC::Transactions.new(@reader).analyze(usd_value) || SEC::TransactionsAlt.new(@reader).analyze(usd_value)
		end

end