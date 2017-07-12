class BC2::AssetTable < BC::AssetTable
	Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		#@account_title = args[0][0] if args.any?
		@title_limit = 2
		#@iterative_title = true
	end

	def parse_position str, type
		return [str,type]
	end

end
