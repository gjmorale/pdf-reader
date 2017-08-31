class CrediCorp::TransactionTable < TransactionTable

	def pre_load *args
		super
		@spanish = 			true
		@label_index = 		5
		@title_limit = 		0
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		5
	end
end

class CrediCorp::CashTransactionTable < CashTransactionTable

	def pre_load *args
		super
		@spanish = 			true
		@label_index = 		5
		@title_limit = 		0
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		5
		@cash_curr = 		"CLP"
	end

	def parse_movement hash
		hash[:value] = hash[:cantidad1]
		case hash[:id_ti_valor1]
		when /^(CLP|USD)$/i
			hash[:id_ti1] = "Currency"
		end
		case hash[:concepto]
		when /(Factura .+)/i
			hash[:invalid] = true
		when /(INGRESO EN C|ABONO USD)/i
			hash[:concepto] = 9001
		when /(CARGOS POR|REGULARIZACI.N OPERACI.N|EGRESO CUENTA|PAGO DOLARES)/i
			hash[:cantidad1] *= -1 unless hash[:cantidad1] == 0
			hash[:concepto] = 9002
		else
			hash[:concepto] = 9000
		end
		hash
	end
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 
