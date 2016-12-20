# Abstract bank class never to be instantiated
class Bank < Institution

	# Accounts to store information
	attr_accessor :accounts
	# Accounts to store information
	attr_accessor :positions

	def print_results  file
		@positions.each do |p|
			file.write(p.print)
		end
	end

end