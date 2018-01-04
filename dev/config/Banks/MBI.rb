require_relative "Bank.rb"

class MBI < Bank
	DIR = "MBI"
	LEGACY = "MBI"
	TABLE_OFFSET = 20
	TEXT_EXPAND = 0.0
end

Dir[File.dirname(__FILE__) + '/MBI/*.rb'].each {|file| require_relative file } 

MBI.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		RUT = 		-1
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'(100|[1-9]\d?)\,\d{2}%|0,00%'
		when Setup::Type::AMOUNT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*,\d\d|0,00)'
		when Setup::Type::INTEGER
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|IP|UF){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'\d{2}(\/\d{2}\/|-\d{2}-)\d{4}'
		when Setup::Type::FLOAT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*(,\d{4})?|0(,0000)?)'
		when Custom::RUT
			'[1-9]\d{0,2}(\.\d{3}){2}-[0-9kK]'
		end
	end

	private  

		def fill_mov mov, acc
			mov.id_fi1 = legacy_code
		end

		def set_date value
			day, month, year = value.split(/\/|-/)
			@date_out = "#{day}-#{month}-#{year}".strip
			puts @date_out
		end

		def analyse_position file
			@reader = Reader.new(file)
			date_field = SingleField.new("Fecha", [Setup::Type::DATE])
			date_field.execute @reader
			format = 1
			unless date_field and date_field.results.any? and date_field.results[0].result != Result::NOT_FOUND 
				date_field = SingleField.new("Fecha Consulta: ", [Setup::Type::DATE])
				date_field.execute @reader
				format = 2
			end
			set_date date_field.results[0].result
			
			case format
			when 1
				@reader.go_to(@reader.page)
				name_field = SingleField.new("Cliente", [Setup::Type::LABEL])
				name_field.execute @reader
				soc_name = name_field.results.first.result
				rut_field = SingleField.new("Rut", [Custom::RUT])
				rut_field.execute @reader
				rut = rut_field.results.first.result
				total_field = SingleField.new("Total Patrimonio", [Setup::Type::INTEGER, Setup::Type::PERCENTAGE])
				total_field.execute @reader
				@total_out = BankUtils.to_number total_field.results.first.result, true
				account = MBI::Account.new("#{rut}#{soc_name[/ - .*$/]}", @total_out)
				@accounts = [account]
				Field.new("Cartera Inversiones").execute @reader
				page = @reader.page
				offset = @reader.offset
				account.add_pos MBI::RVN.new(@reader).analyze
				@reader.go_to(page, offset)
				account.add_pos MBI::Cash.new(@reader).analyze
				@reader.go_to(page, offset)
				account.add_pos MBI::MutualFunds.new(@reader).analyze
				@reader.go_to(page, offset)
				puts "Account #{account.code} total "
				BankUtils.check account.pos_value, account.value
				puts "_____________________________________/"
			when 2
				@total_out = 0
				@accounts = []
			else 
				raise "Unknown MBI format"
			end
=begin

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
=end
		end

end