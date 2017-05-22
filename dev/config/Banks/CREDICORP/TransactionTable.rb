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
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 
