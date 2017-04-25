class BC::TransactionTable < BC::AssetTable
	require File.dirname(__FILE__) + '/BC1/TransactionTable.rb'

	def pre_load *args
		super
		#@account_title = args[0][0] if args.any?
		@label_index = 0
		@title_limit = 0
		@spanish = true
		#@iterative_title = true
	end
end
