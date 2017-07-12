class MSAssetTable < AssetTable

	def pre_load *args
		@label_index = 0
		@title_limit = 2
		@iterative_title = false
	end

	def parse_position str, type
		return [str, nil] unless str.is_a? Multiline and type
		new_name = str.strings[0]
		str.match type do |m|
			code = str.strings[m.offset[2]][m.offset[0]..-1]
			return [code,new_name]
		end
		return [new_name,nil]
	end

	def parse_account str
		if str.is_a? Multiline
			str.strings.each do |s|
				return s if s.match /[0-9]{3}\-[0-9]{6}\-[0-9]{3}\+?/
			end
		else
			return str
		end
	end

end