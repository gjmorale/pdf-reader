class BC::AssetTable < AssetTable
	require File.dirname(__FILE__) + '/BC1/AssetTable.rb' 
	require File.dirname(__FILE__) + '/BC2/AssetTable.rb' 

	def pre_load *args
		super
		@spanish = true
		@label_index = 0
	end
end
