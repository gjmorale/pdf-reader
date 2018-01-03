require_relative "Bank.rb"

class SIGA < Bank
	DIR = "SIGA"
	LEGACY = "Siga"
	TABLE_OFFSET = 20
end

Dir[File.dirname(__FILE__) + '/SIGA/*.rb'].each {|file| require_relative file } 

SIGA.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		RUT = 		-1
		REF_NUM = 	-2
		MOV_CODE = 	-3
		INST_CODE = -4
		CMBTE = 	-5
		TC = 		-6
		OP_LABEL = 	-7
		PB = 		-8
		LONG_ZERO = -9
		FLOAT_3 = 	-10
		FLOAT_4 = 	-11
		NON_ZERO = 	-12
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
		when Custom::RUT
			'\d+(\.\d{3})+-[0-9kK]'
		when Custom::REF_NUM
			'(\d{1,3}(\.\d{3})*(\.\d{2})?|0)'
		when Custom::MOV_CODE
			['('<<
			'ABONO (INTERES|CAPITAL) POR CORTE CUPON',
			'DIVIDENDO EN PESOS',
			'CARGO REG\. (CORTE CUPON|DIVIDENDO)',
			'INGRESO EN CTA CTE\.',
			'FACTURA (COMPRA|VENTA) R.',
			'EGRESO CUENTA CORRIENTE',
			'CANCELA DIVIDENDOS',
			'ABONO POR SORTEO LETRAS'<<
			')'].join('|')
		when Custom::INST_CODE
			'[A-Z0-9\-]{4}[A-Z0-9\-]*'
		when Custom::CMBTE
			'\d{6}'
		when Custom::TC
			'(ET|FD)'
		when Custom::OP_LABEL
			'(Retiro R. Por Sorteo Letras|(Compra|Venta|Vencimiento) R.)'
		when Custom::PB
			'S'
		when Custom::LONG_ZERO
			'1,000000'
		when Custom::FLOAT_4
			'-?((0|[1-9]\d{0,2}(?:,[0-9]{3})*)(\.\d{4})?|0)'
		when Custom::FLOAT_3
			'-?((0|[1-9]\d{0,2}(?:,[0-9]{3})*)(\.\d{3})?|0)'
		when Custom::NON_ZERO
			'-?[1-9]\d{0,2}(?:,[0-9]{3})*'
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

		def analyse_fixed_income
			SIGA::FixedIncome.new(@reader).analyze
		end

		def analyse_cash
			SIGA::CashTransaction.new(@reader).analyze
		end

		def analyse_transactions
			SIGA::Transactions.new(@reader).analyze
		end

		def analyse_variable_income
			checkpoint = @reader.stash
			positions = []
			pos = SIGA::Stock.new(@reader).analyze
			positions += pos if pos
			@reader.pop checkpoint
			checkpoint = @reader.stash
			pos = SIGA::CFI.new(@reader).analyze
			positions += pos if pos
			@reader.pop checkpoint
			pos = SIGA::ETF.new(@reader).analyze
			positions += pos if pos
			return positions
		end

		def analyse_iif
			SIGA::IIF.new(@reader).analyze
		end

end