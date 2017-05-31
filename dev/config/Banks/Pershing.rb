require_relative "Bank.rb"
require 'date'

class PER < Bank
	DIR = "PER"
	LEGACY = "Pershing"
	TABLE_OFFSET = 30
	TEXT_EXPAND = 0.0
	VERTICAL_SEARCH_RANGE = 10
end

module PER::ESP end
module PER::ENG end

Dir[File.dirname(__FILE__) + '/PER/*.rb'].each {|file| require_relative file } 

PER.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		PER_ACC = 	-1
		NUM2 = 		-2
		NUM3 = 		-3
		NUM4 = 		-4
		NO_MM_DATE =-5
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'-?(100|[1-9]?\d\.\d{2})\s?%'
		when Setup::Type::AMOUNT
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)(?:\.\d+)?'
		when Setup::Type::INTEGER
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*[a-zA-Z].*'
		when Setup::Type::DATE
			'(\d{2}\/\d{2}\/\d{2}|Total(\s?Cubierto)?\s*$)'
		when Setup::Type::FLOAT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{4})'
		when Setup::Type::BLANK
			'Impossible Match'
		when Custom::PER_ACC
			'.*[A-Z0-9]+-[0-9]{6}'
		when Custom::NUM2
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)\.\d{2}'
		when Custom::NUM3
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)\.\d{3}'
		when Custom::NUM4
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)\.\d{4}'
		when Custom::NO_MM_DATE
			'(\d{2}\/\d{2}\/\d{2}|Saldo .+$)'
		end
	end

	private  

		def set_date months, value
			date = value.split('-')[1].gsub(',','').split(' ').map{|s| s.strip}
			month = -1
			months.each do |reg|
				if date[0].match reg[1]
					month = reg[0]
					break
				end
			end
			day = date[1]
			year = date[2]
			@date_out = "#{day}-#{month}-#{year}"
			puts (month == -1 ? @date_out.red : @date_out)
		end

		def analyse_position file
			@reader = Reader.new(file)

			eng = !!(@reader.find_text(/Asset Summary/))
			account = nil
			if eng
				factory = PER::ENG
				account = analyse_position_eng factory
			else
				factory = PER::ESP
				account = analyse_position_esp factory
			end
			@accounts = [account]
		end

		def analyse_position_eng factory
			set_date Bank::MONTHS, @reader.find_text(/[A-Z][a-z]{3,9}\s\d\d?,\s20\d\d - [A-Z][a-z]{3,9}\s\d\d?,\s20\d\d/)

			acc_num = SingleField.new("Account Number:", [Custom::PER_ACC],3,Setup::Align::LEFT)
			if acc_num.execute @reader
				acc_name = acc_num.results[0].result
			end

			total = SingleField.new("ENDING ACCOUNT VALUE", [Custom::NUM2],3,Setup::Align::LEFT)
			if total.execute @reader
				@total_out = BankUtils.to_number total.results[0].result
			end

			account = PER::Account.new(acc_name, @total_out)
			puts "\nACC: #{account.code} - #{BankUtils.to_amount account.value}"

			#CASH
			if Field.new("CASH, MONEY FUNDS, AND BANK DEPOSITS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_cash_eng factory
			end

			#Fixed Income
			if Field.new("FIXED INCOME").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_fixed_income factory
			end

			#MutuaFunds
			if Field.new("MUTUAL FUNDS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_mutual_funds factory
			end

			#ETFS
			if Field.new("EXCHANGE-TRADED PRODUCTS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_etfs factory
			end

			#Transactions
			if Field.new("Transactions by Type of Activity").execute @reader
				account.add_mov analyse_transactions_eng factory
			end
			
			#CashMovs
			account.add_mov analyse_cash_transactions factory

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
			return account
		end

		def analyse_position_esp factory
			set_date Bank::MESES, @reader.find_text(/[A-Z][a-z]{3,9}\s\d\d?,\s20\d\d - [A-Z][a-z]{3,9}\s\d\d?,\s20\d\d/)

			acc_num = SingleField.new("Número de Cuenta:", [Custom::PER_ACC],3,Setup::Align::LEFT)
			if acc_num.execute @reader
				acc_name = acc_num.results[0].result
			end

			total = SingleField.new("VALOR FINAL DE LA CUENTA", [Custom::NUM2],3,Setup::Align::LEFT)
			if total.execute @reader
				@total_out = BankUtils.to_number total.results[0].result
			else
				Field.new("Valor de la cuenta al final del período:").execute @reader
				@total_out = BankUtils.to_number @reader.find_text(/-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)\.\d{2}$/, 1, true)
			end

			account = PER::Account.new(acc_name, @total_out)
			puts "\nACC: #{account.code} - #{BankUtils.to_amount account.value}"

			#CASH
			if Field.new("EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS BANCARIOS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_cash_esp factory
			end

			#Fixed Income
			if Field.new("INGRESOS FIJOS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_fixed_income factory
			end

			#MutuaFunds
			if Field.new("FONDOS MUTUOS").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_mutual_funds factory
			end

			#ETFS
			if Field.new("PRODUCTOS NEGOCIADOS EN BOLSA").execute @reader
				@reader.go_to(@reader.page, @reader.offset - 10)
				account.add_pos analyse_etfs factory
			end

			#Transactions
			account.add_mov analyse_transactions factory
			
			#CashMovs
			account.add_mov analyse_cash_transactions factory

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
			return account
		end

		def analyse_etfs factory
			return factory::ETFS.new(@reader).analyze
		end

		def analyse_cash_esp factory
			pos ||= factory::Cash.new(@reader).analyze
			pos ||= factory::CashAlt.new(@reader).analyze
			pos ||= factory::CashEmpty.new(@reader).analyze
			return pos
		end

		def analyse_cash_eng factory
			factory::Cash.new(@reader).analyze
		end

		def analyse_mutual_funds factory
			return factory::MutualFunds.new(@reader).analyze
		end

		def analyse_fixed_income factory
			pos = new_pos = []
			new_pos += pos if(pos = factory::Bonds.new(@reader).analyze)
			new_pos
		end

		def analyse_transactions factory
			pos ||= factory::Transactions.new(@reader).analyze
			pos ||= factory::TransactionsAlt.new(@reader).analyze
			return pos
		end

		def analyse_transactions_eng factory
			pos = new_pos = []
			new_pos += pos if(pos = factory::Dividends.new(@reader).analyze)
			unless(pos = factory::Taxes.new(@reader).analyze)
				@reader.next_page
				pos = factory::Taxes.new(@reader).analyze
			end
			new_pos += pos if pos
			return new_pos
		end

		def analyse_cash_transactions factory
			factory::CashTransactions.new(@reader).analyze
		end
	end
