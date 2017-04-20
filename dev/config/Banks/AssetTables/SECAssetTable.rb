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

class SECTransactionTable < SECAssetTable

	def get_results
		movements = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				movement = new_movement(results)
				movements << movement if movement
			end
		end
		if present
			return movements
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
	end

end