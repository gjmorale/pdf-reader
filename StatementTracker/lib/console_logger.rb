module ConsoleLogger

	def logs **args
		if args[:msg] and @aim == args[:target]
			puts args[:msg] if @verbose.nil? or @verbose
		end
	end

	def logp **args
		@aim = args[:aim] if args[:aim]
		@verbose = !!(args[:verbose]) if args[:verbose]
	end

end