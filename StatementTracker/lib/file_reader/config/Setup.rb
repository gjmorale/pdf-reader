module Setup

	#Has to move to ConsoleLogger
	module Debug

		def self.overview
			return @debug_overview ||= false
		end
		
		def self.overview= value
			@debug_overview = value
		end

	end

	# Field text alignment
	# 8——1——2
	# | \|/ |
	# 7— + —3
	# | /|\ |
	# 6——5——4
	module Align
		TOP = 			1
		TOP_RIGHT = 	2
		RIGHT = 		3
		BOTTOM_RIGHT = 	4
		BOTTOM = 		5
		BOTTOM_LEFT = 	6
		LEFT = 			7
		TOP_LEFT = 		8
	end

	# General data types in documents
	module Type
		PERCENTAGE = 	1
		AMOUNT = 		2
		INTEGER = 		3
		FLOAT = 		4
		CURRENCY = 		5
		ASSET = 		6
		LABEL = 		7
		DATE = 			8
		BLANK = 		9
	end
end