require_relative "Bank.rb"

class BC < Bank
	DIR = "BC"
	LEGACY = "Banchile"
	TABLE_OFFSET = 40
end

module BC1
end
module BC2
end

Dir[File.dirname(__FILE__) + '/BC1/*.rb'].each {|file| require_relative file } 

BC.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		FIN_RUT = -1
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'\$?-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{1,4})?'
		when Setup::Type::INTEGER
			'([1-9]\d{0,2}(?:\.?[0-9]{3})*\)?|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*[a-zA-Z].*'
		when Setup::Type::DATE
			'\d{2}\/\d{2}\/\d{4}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Custom::FIN_RUT
			'\d{3}-[0-9kK]'
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
			account_field_alt = SingleField.new("Subcuenta:", [Setup::Type::INTEGER], 3, Setup::Align::LEFT)

			if account_field.execute @reader
				@accounts = [AccountBC.new(account_field.results[0].result)]
				analyse_position_1 @accounts.first
			elsif account_field_alt.execute @reader
				@accounts = [AccountBC.new(account_field_alt.results[0].result)]
				analyse_position_2 @accounts.first
			else
				puts "Unknown format".red
				@accounts = []
			end

			return
			pershing = SingleField.new("Patrimonio en Custodia Pershing",[Setup::Type::AMOUNT,Setup::Type::AMOUNT])
			pershing.execute @reader
			total_pershing = pershing.results[0].result.gsub('.','').to_f

			total = SingleField.new("TOTAL ACTIVOS",[Setup::Type::AMOUNT], 5, Setup::Align::LEFT)
			total.execute @reader
			@total_out = total.results[0].result.gsub('.','').to_f
			
			account = AccountSEC.new(account_field.results[0].result,@total_out-total_pershing)

			while Field.new("SALDO TOTAL").execute @reader
				#puts "READER BETWEEN SALDOS #@reader"
			end
			@reader.next_page
			
			Field.new("[DETALLE DE INVERSIONES POR CLASE DE ACTIVOS|DETALLE DE INVERSIONES NO PREVISIONALES]").execute @reader
			puts "\nACC: #{account.code} - $#{account.value}"
			account.add_pos analyse_mutual_funds
			account.add_pos analyse_investment_funds
			account.add_pos analyse_stocks
			account.add_pos analyse_bonds
			account.add_pos analyse_cash
			account.add_mov analyse_transactions
			@accounts = [account]

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
		end

		def analyse_position_1 account
			puts "format 1".light_blue
			total = SingleField.new("Total Patrimonio Nacional", BankUtils.to_arr(Setup::Type::AMOUNT, 5), 3, Setup::Align::LEFT)
			total.execute @reader
			@total_out = BankUtils.to_number total.results[3].result, true
			account.value = @total_out

			account.add_pos analyse_mutual_funds BC1

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"

		end

		def analyse_position_2 account
			puts "format 2".light_blue
		end

		def analyse_mutual_funds factory
			new_pos = []
			pos = nil
			new_pos += pos if(pos = factory::MutualFundsCLP.new(@reader).analyze)
			new_pos += pos if(pos = factory::MutualFundsUSD.new(@reader).analyze)
			new_pos
		end
end
