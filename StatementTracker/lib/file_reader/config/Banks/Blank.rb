class BLANK < Institution
	DIR = "BLANK"
	LEGACY = "Bank not yet developed"
	EQS = [
		"Sarasin",
		"Sura",
		"MBI",
		"LV",
		"Euroamerica"
	]

	def eqs
		self.class::EQS
	end

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
	end

	private  

		def analyse_index file
			return [nil, nil]
		end

		def analyse_position file
			@accounts = []
		end
end
