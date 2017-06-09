require_relative "Bank.rb"

class MON < Bank
	DIR = "MON"
	LEGACY = "Moneda"
	HEADER_ORIENTATION = 1
	TABLE_OFFSET = 50
end

Dir[File.dirname(__FILE__) + '/MON/*.rb'].each {|file| require_relative file } 

require File.dirname(__FILE__) + '/MON/Account.rb'
require File.dirname(__FILE__) + '/MON/AssetTable.rb'
if File.exist? File.dirname(__FILE__) + '/MON/TransactionTable.rb'
	require File.dirname(__FILE__) + '/MON/TransactionTable.rb' 
end

MON.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		ACC_RUT = -1
		OP_ID = -2
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100,00|[1-9]?\d\,\d{2})%?'
		when Setup::Type::AMOUNT
			'(-?\(?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{2})?\)?|-)'
		when Setup::Type::INTEGER
			'([-$]?\(?[1-9]\d{0,2}(?:\.?\d{3})*\)?|-|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}(\/|-)\d{2}(\/|-)\d{4}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Setup::Type::BLANK
			'^$'
		when Custom::ACC_RUT
			'\d{7,8}\/\d'
		when Custom::OP_ID
			'\d{6}-\d'
		end
	end

	private  

		def set_date value
			value = value.strip
			day, month, year = value.split('/')
			@date_out = "#{day}-#{month}-#{year}".strip
			puts @date_out
		end

		def analyse_index file
			@reader = Reader.new(file)
			owner = nil
			field = SingleField.new("Cliente:",[Setup::Type::LABEL],3,Setup::Align::LEFT)
			if field.execute @reader
				owner = field.results[0].result.inspect.strip
				owner = nil if owner.empty?
			end
			date_field = SingleField.new("Fecha:",[Setup::Type::DATE])
			date_field.execute @reader
			set_date date_field.results[0].result
			return [owner, @date_out]
		end

		def analyse_position file
			@reader = Reader.new(file)
			account_field = SingleField.new("Id.Cuenta:",[Custom::ACC_RUT])
			account_field.execute @reader
			date_field = SingleField.new("Fecha:",[Setup::Type::DATE])
			date_field.execute @reader
			set_date date_field.results[0].result

			usd = SingleField.new("Valor Dólar Observado",[Setup::Type::AMOUNT])
			if usd.execute @reader and usd.results[0].result != Result::NOT_FOUND
				@usd_value = usd.results[0].result.gsub('.','').gsub(',','.').to_f
				AssetTable.set_currs(usd: @usd_value, clp: 1.0)
			else
				puts "NO USD VALUE DETECTED".red
			end

			total = SingleField.new("Patrimonio Final",[Setup::Type::AMOUNT,Setup::Type::AMOUNT])
			if total.execute @reader
				@total_out = total.results[1].result.gsub('.','').to_f
			else
				activos = SingleField.new("Total Activos",[Setup::Type::PERCENTAGE, Setup::Type::AMOUNT])
				activos.execute @reader
				@total_out = activos.results[1].result.gsub('.','').to_f
				pasivos = SingleField.new("Total Pasivos",[Setup::Type::AMOUNT])
				pasivos.execute @reader
				@total_out -= pasivos.results[0].result.gsub('.','').to_f
			end
			
			account = MON::Account.new(account_field.results[0].result,@total_out)
			@accounts = [account]
			
			puts "\nACC: #{account.code} - #{BankUtils.to_amount account.value}"
			
			@reader.next_page
			start_page = @reader.page

			if Field.new("DETALLE CARTERA DE INVERSIÓN - RENTA FIJA").execute @reader
				puts "#{@reader} Renta VARIABLE"
				account.add_pos analyse_fixed_income
				account.add_pos analyse_mutual_funds
				account.add_pos analyse_bonds
				account.add_pos analyse_intermidiaries
				account.add_pos analyse_others_fixed
			end
			
			@reader.go_to(start_page)

			if Field.new("DETALLE CARTERA DE INVERSIÓN - RENTA VARIABLE").execute @reader
				puts "#{@reader} Renta FIJA"
				account.add_pos analyse_investment_funds
				account.add_pos analyse_stocks
				account.add_pos analyse_real_estate
				account.add_pos analyse_others_variable
			end

			if Field.new("INFORMACIÓN GENERAL")
				account.add_mov analyse_transactions
			end

			if Field.new("CUENTAS CORRIENTES").execute @reader
				checkpoint = @reader.stash
				account.add_pos analyse_cash
				@reader.pop checkpoint
				account.add_mov analyse_cash_transactions
			end

			

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
		end

		def analyse_fixed_income
			new_pos = pos = []
			new_pos += pos if (pos = MON::FixedIncomeCLP.new(@reader).analyze)
			new_pos += pos if (pos = MON::FixedIncomeUSD.new(@reader).analyze)
			new_pos
		end


		def analyse_mutual_funds
			MON::MutualFunds.new(@reader).analyze
		end

		def analyse_bonds
			MON::Bonds.new(@reader).analyze
		end


		def analyse_intermidiaries
			MON::Intermidiaries.new(@reader).analyze
		end

		def analyse_others_fixed
			MON::OthersFixed.new(@reader).analyze
		end

		def analyse_investment_funds
			new_pos = pos = []
			new_pos += pos if (pos = MON::InvestmentFundsCLP.new(@reader).analyze)
			new_pos += pos if (pos = MON::InvestmentFundsUSD.new(@reader).analyze)
			new_pos
		end

		def analyse_stocks
			MON::Stocks.new(@reader).analyze
		end

		def analyse_real_estate
			MON::RealEstate.new(@reader).analyze
		end

		def analyse_others_variable
			MON::OthersVariable.new(@reader).analyze
		end

		def analyse_transactions
			new_mov = mov = []
			new_mov += mov if (mov = MON::Factured.new(@reader).analyze)
			new_mov += mov if (mov = MON::UnFactured.new(@reader).analyze)
			new_mov += mov if (mov = MON::Custody.new(@reader).analyze)
			new_mov
		end

		def analyse_cash
			new_pos = pos = []
			new_pos += pos if (pos = MON::CashCLP.new(@reader).analyze)
			new_pos += pos if (pos = MON::CashUSD.new(@reader).analyze)
			new_pos
		end

		def analyse_cash_transactions
			new_pos = pos = []
			new_pos += pos if (pos = MON::CashTransaction.new(@reader).analyze)
			#new_pos += pos if (pos = MON::CashUSD.new(@reader).analyze)
			new_pos
		end

end