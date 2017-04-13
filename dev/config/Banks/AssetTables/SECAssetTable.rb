class SECAssetTable < AssetTable

	def pre_load *args
		@title_limit = 0
		@label_index = 0
		@spanish = true
	end

	def parse_position str, type
		[str, nil]
	end

	def parse_account str
		raise
	end

end