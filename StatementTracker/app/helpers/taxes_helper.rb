module TaxesHelper

	def to_percentage recieved, expected
		return 100 if expected == 0
		return 100 if recieved >= expected
		return (recieved * 100.0 / expected).to_i
	end

end
