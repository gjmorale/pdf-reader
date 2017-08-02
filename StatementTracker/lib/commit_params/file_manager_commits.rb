class FileManagerCommits

	OPEN = "open".freeze
	USE = "use".freeze

	def initialize(*param_values)
		@param_values = param_values
	end

	def matches?(request)
		@param_values.any?{|prm| request.params[:commit] == prm.to_s}
	end
end