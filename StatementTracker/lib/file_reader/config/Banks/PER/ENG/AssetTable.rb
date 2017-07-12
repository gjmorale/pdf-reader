class PER::ENG::AssetTable < PER::AssetTable

	def each_result_do results, row=nil
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
end