class StatementsCommit

	RELOAD = "statement_reload".freeze
	INDEX = "statement_index".freeze
	INDEXED = "statement_indexed".freeze
	ASSIGN = "statement_assign".freeze
	UNASSIGN = "statement_unassign".freeze
	UPDATE = "statement_update".freeze

	def initialize(*param_values)
		@param_values = param_values
	end

	def matches?(request)
		@param_values.any?{|prm| request.params[:commit] == prm.to_s}
	end
end