class SEC < Institution
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
		OP_CODE = 	-4
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'-?\(?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{1,4})?\)?'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,?[0-9]{3})*\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}\/\d{2}\/\d{4}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Custom::GEST
			'(N|S){1}'
		when Custom::SI_NO
			'(NO|SI|SÍ){1}'
		when Custom::N_CUENTA
			'\d{1,2}'
		when Custom::OP_CODE
			'[A-Z]{2}'
		end
	end

	private  

		def set_date value
			day, month, year = value[value.rindex(' ')..-1].split('-')
			@date_out = "#{day}-#{month}-#{year}".strip
			puts @date_out
		end

		def analyse_index file
			@reader = Reader.new(self, file)
			owner = nil
			set_date @reader.find_text(/ al \d{2}-\d{2}-\d{4}/i)
			field = SingleField.new("Nombre :",[Setup::Type::LABEL],3,Setup::Align::LEFT)
			if field.execute @reader
				owner = field.results[0].result.inspect.strip
				owner = nil if owner.empty?
			end
			return [owner, @date_out]
		end

		def analyse_position file
			@reader = Reader.new(self, file)
			set_date @reader.find_text(/ al \d{2}-\d{2}-\d{4}/i)
			account_field = SingleField.new("Nombre : ", [Setup::Type::LABEL])
			account_field.execute @reader

			usd = SingleField.new("USD:",[Setup::Type::AMOUNT], 3, Setup::Align::LEFT)
			if usd.execute @reader and usd.results[0].result != Result::NOT_FOUND
				@usd_value = usd.results[0].result.gsub('.','').gsub(',','.').to_f
				AssetTable.set_currs(usd: @usd_value)
			else
				puts "NO USD VALUE DETECTED".red
			end
			
			pershing = SingleField.new("Patrimonio en Custodia Pershing",[Setup::Type::AMOUNT,Setup::Type::AMOUNT])
			if pershing.execute @reader
				total_pershing = pershing.results[0].result.gsub('.','').to_f
			else
				total_pershing = 0
			end

			total = SingleField.new("TOTAL ACTIVOS",[Setup::Type::AMOUNT], 5, Setup::Align::LEFT)
			total.execute @reader
			@total_out = total.results[0].result.gsub('.','').to_f
			
			account = AccountSEC.new(account_field.results[0].result,@total_out-total_pershing)

			while Field.new("SALDO TOTAL").execute @reader
				#puts "READER BETWEEN SALDOS #@reader"
			end
			@reader.next_page
			
			#Field.new("[DETALLE DE INVERSIONES POR CLASE DE ACTIVOS|DETALLE DE INVERSIONES NO PREVISIONALES]").execute @reader
			puts "\nACC: #{account.code} - #{BankUtils.to_amount account.value}"
			account.add_pos analyse_mutual_funds
			account.add_pos analyse_investment_funds
			account.add_pos analyse_stocks
			account.add_pos analyse_bonds
			account.add_pos analyse_cash
			account.add_pos analyse_others
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
			new_positions = pos = []
			new_positions += pos if(pos = SEC::InvFundsCLP.new(@reader).analyze)
			new_positions += pos if(pos = SEC::InvFundsUSD.new(@reader).analyze)
			return new_positions
			
		end

		def analyse_cash
			SEC::Cash.new(@reader).analyze
		end

		def analyse_stocks
			SEC::Stocks.new(@reader).analyze
		end

		def analyse_bonds
			new_positions = pos = []
			new_positions += pos if(pos = SEC::BondsCLP.new(@reader).analyze)
			return new_positions
		end

		def analyse_others
			SEC::Others.new(@reader).analyze
		end

		def analyse_transactions
			new_movements = SEC::Transactions.new(@reader).analyze(usd_value) || 
				SEC::TransactionsAlt.new(@reader).analyze
			while moves = SEC::CashTransactions.new(@reader).analyze
				new_movements += moves
			end
			new_movements
		end

end