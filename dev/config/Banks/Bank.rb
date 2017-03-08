# Abstract bank class never to be instantiated
class Bank < Institution

	# Accounts to store information
	attr_accessor :accounts

	def print_results  file
		positions = []
		@accounts.map{|a| positions += a.positions}
		positions.each do |p|
			file.write(p.print)
		end
	end

end