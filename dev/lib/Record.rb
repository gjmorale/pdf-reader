class Record

	def initialize (name, bonif_1, cap_1, bonif_2, cap_2)
		@name = name
		@bonif_1 = bonif_1
		@cap_1 = cap_1
		@bonif_2 = bonif_2
		@cap_2 = cap_2
	end

	def print
		"\n#{@name};#{@bonif_1};#{@cap_1};#{@bonif_2};#{@cap_2}"
	end

end