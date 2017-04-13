require_relative "Bank.rb"

class SEC < Bank
	DIR = "SEC"
	LEGACY = "Security"
	TEXT_EXPAND = 0.0
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
			'\(?[0-9]{1,3}(?:.?[0-9]{3})*(\,[0-9]{1,4})?\)?'
		when Setup::Type::INTEGER
			'([$]?\(?[1-9]\d{0,2}(?:,?[0-9]{3})*\)?|(?:\342\200\224)){1}\s*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY|GBP){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}-\d{2}-\d{4}'
		when Setup::Type::FLOAT
			'(\(?(?:[1-9]{1}\d*|0)\.\d+\)?|(?:\342\200\224)){1}'
		when Custom::GEST
			'(N){1}'
		when Custom::SI_NO
			'(NO|SI|SÍ){1}'
		when Custom::N_CUENTA
			'[1-9]\d?'
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
			account = SingleField.new("Nombre : ", [Setup::Type::LABEL])
			account.execute @reader
			total = SingleField.new("TOTAL ACTIVOS",[Setup::Type::AMOUNT])
			total.execute @reader
			@total_out = total.results[0].result.to_f
			@accounts = [AccountSEC.new(account.results[0].result,@total_out)]
			while Field.new("SALDO TOTAL").execute @reader
			end
			@reader.next_page
			@accounts.each do |account|
				Field.new("DETALLE DE INVERSIONES POR CLASE DE ACTIVOS").execute @reader
				puts "\nACC: #{account.code} - $#{account.value}"
				account.add_pos analyse_mutual_funds
				account.add_pos analyse_fixed_income
				account.add_pos analyse_cash
				account.add_pos analyse_stock
				account.add_pos analyse_etfs
				account.add_pos analyse_government_securities
				account.add_pos analyse_alternative_investments

				puts "Account #{account.code} total "
				BankUtils.check account.pos_value, account.value
				puts "_____________________________________/"
			end
			get_grand_total
		end

		def get_grand_total
			@reader.go_to 1
			total = SingleField.new("$", [Setup::Type::AMOUNT])
			total.execute @reader
			acumulated = 0
			accounts.map{|p| acumulated += p.pos_value}
			puts "\nGRAND TOTAL: "
			BankUtils.check acumulated, to_number(total.results[0].result)
			puts "_____________________________________/"
			@total_out = to_number(total.results[0].result)
		end

		def analyse_mutual_funds
			SEC::MutualFunds.new(@reader).analyze
		end

		def analyse_fixed_income
			SEC::FixedIncome.new(@reader).analyze
		end

end