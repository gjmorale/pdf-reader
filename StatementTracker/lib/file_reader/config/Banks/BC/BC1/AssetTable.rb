class BC1::AssetTable < BC::AssetTable
	Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		@title_limit = 0
	end

	def parse_position str, type
		return [str,type]
	end

end
