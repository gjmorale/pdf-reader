require_relative "Bank.rb"
require 'date'

class CrediCorp < Bank
	DIR = "CREDICORP"
	LEGACY = "CrediCorp"
	TEXT_EXPAND = 0.0
	TABLE_OFFSET = 20
end

Dir[File.dirname(__FILE__) + '/CREDICORP/*.rb'].each {|file| require_relative file } 

CrediCorp.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		AMOUNT_USD = 	-1
		ASSET_LABEL = 	-2
		SERIES_CODE = 	-3
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d),\d{2}\s?%'
		when Setup::Type::AMOUNT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{1,4})?'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,?[0-9]{3})*\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}-\d{2}-\d{4}'
		when Setup::Type::FLOAT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{4})'
		when Custom::ASSET_LABEL
			'[A-Z_1-9]+(\s[A-Z_1-9]+){0,7}(\s?\(AGF\))?'
		when Custom::SERIES_CODE
			'[BIU]'
		when Custom::AMOUNT_USD
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{2})?'
		end
	end

	private  

		def set_date value1, value2
			day, month, year = value2.split('-')
			if value2.eql? value1
				date = Date.strptime(value1, "%d-%m-%Y")
				day = date.next_month.prev_day.day
			end
			@date_out = "#{day}-#{month}-#{year}"
			puts @date_out
		end

		def analyse_position file
			@reader = Reader.new(file)
			acc_num = SingleField.new("Cuenta(s)",[Setup::Type::INTEGER])
			acc_num.execute @reader
			f_desde = SingleField.new("Desde",[Setup::Type::DATE])
			f_desde.execute @reader
			f_hasta = SingleField.new("Hasta",[Setup::Type::DATE])
			f_hasta.execute @reader
			set_date f_desde.results[0].result, f_hasta.results[0].result
			usd = SingleField.new("Valor USD Cierre",[Setup::Type::AMOUNT])
			if usd.execute @reader and usd.results[0].result != Result::NOT_FOUND
				@usd_value = BankUtils.to_number usd.results[0].result, true
				AssetTable.set_currs(usd: @usd_value)
			else
				puts "NO USD VALUE DETECTED".red
			end
			@reader.next_page
			total = SingleField.new("TOTALES",[Setup::Type::AMOUNT,Custom::AMOUNT_USD,Setup::Type::PERCENTAGE],3,Setup::Align::LEFT)
			total.execute @reader
			clp_total = BankUtils.to_number(total.results[0].result, true)
			@total_out = clp_total
			account = CrediCorp::Account.new(acc_num.results[0].result.inspect,@total_out)
			@accounts = [account]
			puts "\nACC: #{account.code} - $#{account.value}"

			if Field.new("DETALLE CARTERA RENTA VARIABLE").execute @reader
				puts "RENTA VARIABLE:"
				account.add_pos analyse_mutual_funds
			end
			
			if Field.new("DETALLE CARTERA RENTA FIJA").execute @reader
				puts "RENTA FIJA:"
				account.add_pos analyse_mutual_funds
				account.add_pos analyse_investment_funds
			end
			
			if Field.new("DETALLE CARTERA ALTERNATIVOS").execute @reader
				puts "ALTERNATIVOS:"
				account.add_pos analyse_investment_funds
			end

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, @total_out
			puts "_____________________________________/"
		end

		def analyse_mutual_funds
			pos = new_pos = []
			new_pos += pos if(pos = CrediCorp::MutualFundsCLP.new(@reader).analyze)
			new_pos += pos if(pos = CrediCorp::MutualFundsUSD.new(@reader).analyze)
			@reader.next_page if new_pos.any?
			new_pos
		end

		def analyse_investment_funds
			pos = new_pos = []
			new_pos += pos if(pos = CrediCorp::InvestmentFundsCLP.new(@reader).analyze)
			new_pos += pos if(pos = CrediCorp::InvestmentFundsUSD.new(@reader).analyze)
			new_pos
		end

end