
class SAN1::AssetTable < AssetTable

	def pre_load *args
		super
		@spanish = true
	end
end


Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 