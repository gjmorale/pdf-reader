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

	def parse_movement hash
		c = hash[:concepto]
		hash[:concepto] = c
		if c =~ /(Venta|Rescate|Sorteo)/i
			hash[:codigo] = 9005
			hash[:cantidad2] -= hash[:delta]
		elsif c =~ /(Compra|Inversi.n)/i
			hash[:codigo] = 9004
			hash[:cantidad2] += hash[:delta]
		elsif c =~ /(Dividendo)/i
			hash[:codigo] = 9006
			hash[:cantidad2] += hash[:delta]
		elsif c =~ /(Corte Cup[oóOÓ]n)/i
			hash[:codigo] = 9007
			hash[:cantidad2] -= hash[:delta]
			hash[:cantidad1] = 0.0
		else
			hash[:codigo] = 9000
		end
		return hash
	end

end