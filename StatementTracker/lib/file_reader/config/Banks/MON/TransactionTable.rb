class MON::TransactionTable < TransactionTable

	def pre_load *args
		super
		@spanish = true
		@label_index = 0
		@title_limit = 0
	end
end

class MON::CashTransactionTable < CashTransactionTable

	def pre_load *args
		super
		@spanish = true
		@label_index = 0
		@title_limit = 0
	end
end

Dir[File.dirname(__FILE__) + '/TransactionTables/*.rb'].each {|file| require_relative file } 