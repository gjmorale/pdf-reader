class EqsCommit

	SOC_UPDATE = "eq_societies_update".freeze

	def initialize(*param_values)
		@param_values = param_values
	end

	def matches?(request)
		@param_values.any?{|prm| request.params[:commit] == prm.to_s}
	end
end