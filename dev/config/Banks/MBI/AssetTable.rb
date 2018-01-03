class MBI::AssetTable < AssetTable
	Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		@spanish = true
		@title_limit = 3
	end
end
