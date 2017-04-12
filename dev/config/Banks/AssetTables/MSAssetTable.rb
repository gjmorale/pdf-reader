class MSAssetTable < AssetTable


	def parse_position str, type
		return [name, nil] unless str.is_a? Multiline and type
		name = str.strings[0]
		regex = Regexp.new type
		str.match type do |m|
			code = str.strings[m.offset[2]][m.offset[0]..-1]
			return [code,name]
		end
		return [name,nil]
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