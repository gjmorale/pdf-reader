require_relative "Bank.rb"

class SAN1 < Bank
	DIR = "SAN1"
	LEGACY = "Santander"
	TABLE_OFFSET = 20
	TEXT_EXPAND = 0
end

Dir[File.dirname(__FILE__) + '/SAN/SAN1/*.rb'].each {|file| require_relative file } 

SAN1.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module SAN1::Custom
		SAN1::Custom::RUT = 			-1
		SAN1::Custom::FINAL_PAT = -2
		SAN1::Custom::FLOAT4 = 		-3
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'([+-]?\(?(100|[1-9]?\d)\.\d{2}\)?%|(?:\342\200\224)){1}\s*'
		when Setup::Type::AMOUNT
			' ?\$\d{1,3}(\.\d{3})*'
		when Setup::Type::INTEGER
			' ?-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)'
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
		when Setup::Type::BLANK
			''
		when SAN1::Custom::RUT
			'\d+(\,\d{3})+-[0-9kK]'
		when SAN1::Custom::FINAL_PAT
			'SALDO ?FINAL ?'
		when SAN1::Custom::FLOAT4
			' ?-?([1-9]\d{0,2}(\.\d{3})*|0)\,\d{4}'
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

			account_field = SingleField.new("N° PARTICIPE :", [SAN1::Custom::RUT])
			account_field.execute @reader

			date_field = SingleField.new("Hasta ", [Setup::Type::DATE])
			date_field.execute @reader
			set_date date_field.results[0].result

			total = SingleField.new("SALDO FINAL ",[Setup::Type::AMOUNT, SAN1::Custom::FINAL_PAT, Setup::Type::AMOUNT])
			if total.execute @reader
				@total_out = total.results[2].result.gsub(/[\.\$]/,'').to_f
			else
				@total_out = 0
			end
			account = SAN1::Account.new(account_field.results[0].result, @total_out)

			@reader.go_to 1

			account.add_pos analyse_mf_pos
			account.add_mov analyse_mf_mov

			puts "Account #{account.code} total "
			BankUtils.check account.pos_value, account.value
			puts "_____________________________________/"
			@accounts = [account]
		end

		def analyse_mf_pos
			SAN1::MFPos.new(@reader).analyze
		end

		def analyse_mf_mov
			movs = []
			movs += SAN1::Internal.new(@reader).analyze || []
			movs += SAN1::External.new(@reader).analyze || []
			movs += SAN1::Dividends.new(@reader).analyze || []
			movs
		end
end