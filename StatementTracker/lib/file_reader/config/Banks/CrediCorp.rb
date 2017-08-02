class CrediCorp < Institution
	DIR = "CORP"
	LEGACY = "CrediCorp"
	TEXT_EXPAND = 0.0
	TABLE_OFFSET = 30
	EQS = [
		"CrediCorp",
		"CC",
		"CCorp",
		"Credicorp"
	]
end

Dir[File.dirname(__FILE__) + '/CORP/*.rb'].each {|file| require_relative file } 

CrediCorp.class_eval do

	def eqs
		self.class::EQS
	end

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
		ACC_CODES = 	-4
		OPERATION = 	-5
		MOV_ID = 	-6
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d,\d{2})\s?%'
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
		when Setup::Type::BLANK
			'Impossible Match'
		when Custom::ASSET_LABEL
			'[A-Z_1-9]+((\s|-)[A-Z_1-9]+){0,7}(\s?\(AGF\))?'
		when Custom::SERIES_CODE
			'[BIU]'
		when Custom::AMOUNT_USD
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{2})?'
		when Custom::ACC_CODES
			'[0-9]{1,2}(,\s?[0-9]{1,2})*'
		when Custom::OPERATION
			'(VENTA|COMPRA|RETIRO|APORTE|INGRESO).(FONDOS?\s?MUTUOS?|RV|POR\s?CANJE\s?DE\s?INSTRUMENTO)'
		when Custom::MOV_ID
			'(15\d{6}|(3|6)\d{5})'
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

		def analyse_index file
			@reader = Reader.new(self, file)
			owner = nil
			field = SingleField.new("RUT",[Setup::Type::LABEL],3,Setup::Align::LEFT)
			if field.execute @reader
				owner = field.results[0].result.inspect.strip
				owner = nil if owner.empty?
			end
			f_desde = SingleField.new("Desde",[Setup::Type::DATE])
			f_desde.execute @reader
			f_hasta = SingleField.new("Hasta",[Setup::Type::DATE])
			f_hasta.execute @reader
			set_date f_desde.results[0].result, f_hasta.results[0].result
			return [owner, @date_out]
		end

		def analyse_position file
			@reader = Reader.new(self, file)
			acc_num = SingleField.new("Cuenta(s)",[Custom::ACC_CODES])
			acc_num.execute @reader
			acc_nums = acc_num.results[0].result.split(',')
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

			total_consolidated = Field.new("RESUMEN CONSOLIDADO DE CUENTAS")
			if total_consolidated.execute @reader
				total = SingleField.new("TOTALES",[Setup::Type::AMOUNT,Custom::AMOUNT_USD,Setup::Type::PERCENTAGE],3,Setup::Align::LEFT)
				total.execute @reader
				@total_out = BankUtils.to_number(total.results[0].result, true)
			else
				@total_out = nil
			end
			@accounts = []
			acc_nums.each do |code|
				Field.new("RESUMEN DE CUENTA").execute @reader
				cash = SingleField.new("Caja",[Setup::Type::AMOUNT,Custom::AMOUNT_USD,Setup::Type::PERCENTAGE],3,Setup::Align::LEFT)
				cash.execute @reader
				cash_total = BankUtils.to_number(cash.results[0].result, true)

				total = SingleField.new("TOTALES",[Setup::Type::AMOUNT,Custom::AMOUNT_USD,Setup::Type::PERCENTAGE],3,Setup::Align::LEFT)
				total.execute @reader
				clp_total = BankUtils.to_number(total.results[0].result, true)
				@total_out ||= clp_total

				account = CrediCorp::Account.new(code,clp_total)
				@accounts << account
				account.add_pos Position.new("CAJA", cash_total, 1.0, cash_total)
				puts "\nACC: #{account.code} - #{BankUtils.to_amount account.value}"

				if Field.new("DETALLE CARTERA RENTA VARIABLE").execute @reader, 5
					puts "RENTA VARIABLE:"
					account.add_pos analyse_mutual_funds
					account.add_pos analyse_investment_funds
					account.add_pos analyse_stocks
				end
				
				if Field.new("DETALLE CARTERA RENTA FIJA").execute @reader, 5
					puts "RENTA FIJA:"
					account.add_pos analyse_mutual_funds
					account.add_pos analyse_investment_funds
				end
				
				if Field.new("DETALLE CARTERA ALTERNATIVOS").execute @reader, 5
					puts "ALTERNATIVOS:"
					account.add_pos analyse_investment_funds
				end
				
				cash_movs = movs = []

				if Field.new("MOVIMIENTO DE CAJA").execute @reader, 5
					puts "MOVIMIENTOS DE CAJA:"
					cash_movs = analyse_cash_movs
				end
				
				if Field.new("MOVIMIENTOS DE TÍTULOS").execute @reader, 5
					puts "MOVIMIENTOS DE TÍTULOS:"
					movs = analyse_custody
				end

				account.add_mov check_movs cash_movs, movs

				puts "Account #{account.code} total "
				BankUtils.check account.pos_value, account.value
				puts "_____________________________________/"
			end

			if @accounts.size > 1
				puts "Grand total "
				BankUtils.check @accounts.inject(0){|accum, acc| accum += acc.pos_value}, @total_out
				puts "_____________________________________/"
			end
		end

		def check_movs cash_movs, movs
			new_movs = []
			cash_movs.each do |cash_mov|
				id = cash_mov.detalle
				cash = -1*cash_mov.value
				afected_movs = movs.select {|m| m.detalle.eql? id}
				unafected_movs = movs.select {|m| not m.detalle.eql? id}
				total = afected_movs.inject(0) {|accum, m| accum += m.value}
				afected_movs.map {|m| m.value += (cash-total)*m.value/total}
				new_movs += afected_movs
				new_movs += unafected_movs
			end
			new_movs += cash_movs
			new_movs
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

		def analyse_stocks
			pos = new_pos = []
			new_pos += pos if(pos = CrediCorp::StocksCLP.new(@reader).analyze)
			new_pos += pos if(pos = CrediCorp::StocksUSD.new(@reader).analyze)
			new_pos
		end

		def analyse_custody
			return CrediCorp::Custody.new(@reader).analyze
		end

		def analyse_cash_movs
			mov = new_mov = []
			new_mov += mov if(mov = CrediCorp::CashMovCLP.new(@reader).analyze)
			new_mov += mov if(mov = CrediCorp::CashMovUSD.new(@reader).analyze)
			return new_mov
		end

end