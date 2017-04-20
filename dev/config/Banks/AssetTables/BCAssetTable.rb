class BCAssetTable < AssetTable
end

class BC1AssetTable < BCAssetTable

	def pre_load *args
		#@account_title = args[0][0] if args.any?
		@label_index = 1
		@title_limit = 0
		@spanish = true
		#@iterative_title = true
	end

	def parse_position str, type
		return [str,type]
	end

end