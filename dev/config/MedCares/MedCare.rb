# Abstract bank class never to be instantiated
class Medcare < Institution

	HEADERS = ["ATENCIÓN",
			"% DE BONIFICACIÓN",
			"TOPE",
			"% DE BONIFICACIÓN",
			"TOPE"]

	def print_results  file
		heading = ""
		HEADERS.each.with_index do |h, i|
			heading << h
			heading << ';' unless i == HEADERS.size-1
		end
		file.write(heading)
		@accounts.each do |account|
			file.write(account.print)
			account.elements.reverse_each do |record|
				file.write(record.print)
			end
		end
	end

end