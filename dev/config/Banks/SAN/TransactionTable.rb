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
			hash[:detalle] 	= "#{args[1]}".strip
			hash[:fecha]	= SAN.value_to_date("#{args[2]}".strip) || hash[:fecha_movimiento]
			hash[:monto] = BankUtils.to_number(args[3]) + BankUtils.to_number(args[4])
			hash[:value] = hash[:monto]
			case args[1]
			when /Saldo inicial/
				hash[:concepto] = 0
				hash[:value] = BankUtils.to_number(args[5])
				hash[:detalle] = "Saldo inicial"
			when /TRANSFER BILL PAYMENT/
				hash[:concepto] = "Transferencia cuenta corriente"
				hash[:descripcion] = "Transferencia #{hash[:value] > 0 ? 'de' : 'a'} #{segments.last}"
				hash[:currency] = @alt_currency.upcase
			when /OUR ACCOUNT PAY CREDIT/
				hash[:concepto] = "Compras"
				hash[:currency] = @alt_currency.upcase
				hash[:forward_id] = segments[1].strip[/(?<=fx)\d+/i].to_i
				hash[:descripcion] = "Se compraron #{hash[:currency]} #{hash[:monto]}"
			when /CURRENCY PURCHASE/
				hash[:concepto] = "Ventas"
				hash[:currency] = @alt_currency.upcase
				hash[:forward_id] = segments[1].strip[/(?<=fx)\d+/i].to_i
				hash[:descripcion] = "Se vendieron #{hash[:currency]} #{-hash[:monto]}"
			when /(CHEQUE|OUTWARD FED PAYMENT|SWIFT PAYMENT|ACH TRANSACTION)/
				hash[:concepto] = "Transferencia cuenta corriente"
				hash[:currency] = @alt_currency.upcase
				hash[:descripcion] = "#{hash[:value] > 0 ? 'Ingreso' : 'Egreso'} de #{hash[:currency]}"
			when /INTERNAL TRANSFER/
				hash[:concepto] = "Transferencia cuenta corriente"
				hash[:descripcion] = "Transferencia #{hash[:value] > 0 ? 'de' : 'a'} #{segments.last}"
				hash[:currency] = @alt_currency.upcase
			when /SECURITIES SALE/
				hash[:concepto] = "Ventas"
				cantidad = BankUtils.to_number(segments.last.split(' - ')[0])
				instrumento = segments.last.split(' - ')[1]
				hash[:descripcion] = "Venta de #{cantidad} unidades de #{instrumento}"
				hash[:currency] = @alt_currency.upcase
			when /SECURITIES PURCHASE/
				hash[:concepto] = "Compras"
				cantidad = BankUtils.to_number(segments.last.split(' - ')[0])
				instrumento = segments.last.split(' - ')[1]
				hash[:descripcion] = "Compra de #{cantidad} unidades de #{instrumento}"
				hash[:currency] = @alt_currency.upcase
			when /COUPONS.+(ANNUAL CASH DIVIDEND|CASH DIVIDEND|CASH)/
				hash[:concepto] = "Dividendos extranjeros"
				instrumento = segments.join(' ').split(' - ')[1].gsub(/^[0-9\. ]+/,'')
				hash[:descripcion] = "Dividendos de #{instrumento}"
				hash[:currency] = @alt_currency.upcase
			when /(FEES ADJUSTMENT|MANAGEMENT FEES|NON-DISCRETIONARY FEES|QUARTERLY MAINTENANCE FEE)/
				hash[:concepto] = "Comisiones"
				hash[:descripcion] = "Comisiones #{ "negativas" if hash[:value] > 0 } por mantención"
				hash[:currency] = @alt_currency.upcase
			when /COUPON PAYMENT/
				hash[:concepto] = "Dividendos extranjeros"
				instrument = segments.join(' ').split(' - ')[1]
				hash[:descripcion] = "Pago de cupón de #{instrument}"
				hash[:currency] = @alt_currency.upcase
			when /CREDIT INTEREST|DEBIT INTEREST/
				hash[:concepto] = "Intereses ganados"
				hash[:descripcion] = "#{ hash[:value] > 0 ? "Cobro" : "Pago" } de intereses"
				hash[:currency] = @alt_currency.upcase
			else
				return nil
			end
			#puts "#{hash[:concepto]}: #{hash[:value]} - #{hash[:detalle]}"
			(hash[:descripcion] << ", completado al " + SAN.value_to_date("#{args[0]}".strip).to_s) if hash[:descripcion] and not hash[:forward_id]
			return SAN::Movement.new(hash)
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
