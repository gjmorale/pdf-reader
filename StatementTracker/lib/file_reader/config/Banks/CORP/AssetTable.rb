class CrediCorp::AssetTable < AssetTable
	Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		@spanish = 			true
		@label_index = 		0
		@title_limit = 		2
		@dont_move = 		true
		@require_rows = 	true
		@require_offset = 	true
	end
end