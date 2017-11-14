class SAN::TransactionTable < TransactionTable


	def pre_load *args
		AssetTable.set_currs usd: 1.0, jpy: 1.0, eur: 1.0
		super
	end

	def each_result_do results, row = nil
		#Override for custom result handling
		return unless results[0] == Result::NOT_FOUND
		puts results
		puts row
	end

	def new_movement args
		if args[1] != Result::NOT_FOUND
			segments = args[1].strings.join('/').split('/').select{|s| not s.strip.empty? }
			hash = {}
			hash[:detalle] = "#{args[1]}".strip
			hash[:fecha_movimiento] = SAN.value_to_date("#{args[0]}".strip)
			hash[:fecha_pago] 		= SAN.value_to_date("#{args[2]}".strip) || hash[:fecha_movimiento]
			case args[1]
			when /Saldo inicial/
				hash[:concepto] = 0
				hash[:value] = BankUtils.to_number(args[5])
				hash[:detalle] = "Saldo inicial"
			when /TRANSFER BILL PAYMENT/
				hash[:concepto] = 9013
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad1]
			when /OUR ACCOUNT PAY CREDIT/
				hash[:concepto] = 9991
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad1]
				hash[:forward_id] = args[1].split('/')[1].strip
			when /CURRENCY PURCHASE/
				hash[:concepto] = 9990
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = -BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] -= BankUtils.to_number(args[4], spanish)
				hash[:value] = -hash[:cantidad1]
				hash[:forward_id] = args[1].split('/')[1].strip
			when /(CHEQUE|OUTWARD FED PAYMENT|SWIFT PAYMENT|ACH TRANSACTION)/
				hash[:concepto] = 9002
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = -BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] -= BankUtils.to_number(args[4], spanish)
				hash[:value] = -hash[:cantidad1]
			when /INTERNAL TRANSFER/
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = -BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] -= BankUtils.to_number(args[4], spanish)
				hash[:value] = -hash[:cantidad1]
				hash[:concepto] = hash[:cantidad1] > 0 ? 9002 : 9001
				hash[:cantidad1] = hash[:cantidad1].abs
			when /SECURITIES SALE/
				hash[:concepto] = 9005
				hash[:id_ti_valor1] = segments.last.split(' - ')[1]
				hash[:cantidad1] = BankUtils.to_number(segments.last.split(' - ')[0])
				hash[:id_ti_valor2] = @alt_currency.upcase
				hash[:id_ti2] = "Currency"
				hash[:cantidad2] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad2] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad2]
			when /SECURITIES PURCHASE/
				hash[:concepto] = 9004
				hash[:id_ti_valor1] = segments.last.split(' - ')[1]
				hash[:cantidad1] = BankUtils.to_number(segments.last.split(' - ')[0])
				hash[:id_ti_valor2] = @alt_currency.upcase
				hash[:cantidad2] = -BankUtils.to_number(args[3], spanish)
				hash[:cantidad2] -= BankUtils.to_number(args[4], spanish)
				hash[:value] = -hash[:cantidad2]
			when /COUPONS.+(ANNUAL CASH DIVIDEND|CASH DIVIDEND|CASH)/
				hash[:concepto] = 9006
				hash[:id_ti_valor1] = segments.join(' ').split(' - ')[1].gsub(/^[0-9\. ]+/,'')
				hash[:cantidad1] = 0.0
				hash[:id_ti_valor2] = @alt_currency.upcase
				hash[:id_ti2] = "Currency"
				hash[:cantidad2] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad2] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad2]
			when /(FEES ADJUSTMENT|MANAGEMENT FEES|DEBIT INTEREST|NON-DISCRETIONARY FEES|QUARTERLY MAINTENANCE FEE)/
				hash[:concepto] = 9013
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = -BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] -= BankUtils.to_number(args[4], spanish)
				hash[:value] = -hash[:cantidad1]
			when /COUPON PAYMENT/
				hash[:concepto] = 9007
				hash[:id_ti_valor1] = segments.join(' ').split(' - ')[1]
				hash[:cantidad1] = 0.0
				hash[:id_ti_valor2] = @alt_currency.upcase
				hash[:id_ti2] = "Currency"
				hash[:cantidad2] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad2] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad2]
			when /CREDIT INTEREST/
				hash[:concepto] = 9014
				hash[:id_ti_valor1] = @alt_currency.upcase
				hash[:id_ti1] = "Currency"
				hash[:cantidad1] = BankUtils.to_number(args[3], spanish)
				hash[:cantidad1] += BankUtils.to_number(args[4], spanish)
				hash[:value] = hash[:cantidad1]
			else
				return nil
			end
			#puts "#{hash[:concepto]}: #{hash[:value]} - #{hash[:detalle]}"
			return Movement.new(hash)
		end
		return nil
	end

	def post_check_do new_positions
		initial_amount = new_positions.select{|p| p.detalle =~ /Saldo inicial/i}
		if initial_amount and initial_amount.any?
			initial_amount = initial_amount.first
			new_positions.delete initial_amount 
		else 
			raise
		end
		return new_positions
	end
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 
