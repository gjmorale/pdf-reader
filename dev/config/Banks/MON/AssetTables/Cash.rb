class MON::Cash < MON::AssetTable
	def get_results
		final_position = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				if results[3] =~ /SALDO FINAL/i
					final_position << new_cash_position(@moneda, results[@value_index])
				end
			end
		end
		if present
			return final_position
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

	def new_cash_position currency, value 
		value = BankUtils.to_number(value, spanish)
		price = @@alt_currs[@moneda.to_sym] if @moneda
		quantity = value/price
		Position.new("Caja en #{@moneda}", 
			quantity, 
			price, 
			value,
			"")
	end
end

class MON::CashCLP < MON::Cash
	def load
		@name = "caja en clp"
		@title = [Field.new("INFORME DE CAJA-MONEDA : PESO"),Field.new("INFORME DE CAJA (CAJA PESO) - MONEDA : PESO")]
		@table_end = Field.new("Información Adicional")
		@headers = []
			headers << HeaderField.new("Folio", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Factura", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Movimiento", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Ingreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Egreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@value_index = 		6
		@moneda = 			:clp
	end

end

class MON::CashUSD < MON::Cash
	def load
		@name = "caja en usd"
		@title = [Field.new("INFORME DE CAJA-MONEDA : DÓLAR"),Field.new("INFORME DE CAJA (CAJA DÓLAR) - MONEDA : DÓLAR")]
		@table_end = Field.new("Información Adicional")
		@headers = []
			headers << HeaderField.new("Folio", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Fecha", headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Factura", headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Movimiento", headers.size, Setup::Type::LABEL, true)
			headers << HeaderField.new("Ingreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Egreso", headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Saldo", headers.size, Setup::Type::AMOUNT)
		@page_end = 		Field.new("http://mgi.moneda.cl")
		@value_index = 		6
		@moneda = 			:usd
	end

end

