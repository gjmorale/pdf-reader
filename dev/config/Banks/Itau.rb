require_relative "Bank.rb"

class ITAU < Bank
	DIR = "ITAU"
	LEGACY = "Itau"
	TABLE_OFFSET = 20
end

Dir[File.dirname(__FILE__) + '/ITAU/*.rb'].each {|file| require_relative file } 

ITAU.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			'-?((0|[1-9]\d{0,2}(?:\.[0-9]{3})*),\d\d|0)'
		when Setup::Type::INTEGER
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|IP|UF){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}\/\d{2}\/\d{4}'
		when Setup::Type::FLOAT
			'-?((0|[1-9]\d{0,2}(?:\.[0-9]{3})*),\d\d|0){3}'
		end
	end


	private  

		def fill_mov mov, acc
			mov.id_fi1 = legacy_code
		end

		def set_date value
			day, month, year = value.split('/')
			@date_out = "#{day}-#{month}-#{year}".strip
			puts @date_out
		end

		def analyse_position file
			@reader = Reader.new(file)
			date_field = SingleField.new("Hasta:", [Setup::Type::DATE])
			date_field.execute @reader
			set_date date_field.results[0].result

			cue = @reader.stash
			cash_field = SingleField.new("Caja", [Setup::Type::INTEGER])
			cash_field.execute @reader
			cash = cash_field.results[0].result.gsub(/\./,'').to_f
			@reader.pop cue

			account_field = SingleField.new("RUT:", [Custom::RUT])
			account_field.execute @reader

			total = SingleField.new("Pesos (CLP)",[Setup::Type::INTEGER])
			if total.execute @reader
				@total_out = total.results[0].result.gsub(/\./,'').to_f
			else
				@total_out = 0
			end
			account = SIGA::Account.new(account_field.results[0].result, @total_out)
			@reader.next_page

			account.add_pos [Position.new("Caja", cash, "CLP", cash)]

			account.add_pos analyse_fixed_income
			account.add_pos analyse_variable_income
			account.add_pos analyse_iif

			account.add_mov analyse_cash
			account.add_mov analyse_transactions
			account.adjust_movs

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
			@accounts = [account]
		end

end