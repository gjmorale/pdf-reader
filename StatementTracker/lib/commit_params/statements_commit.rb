class StatementsCommit

	RELOAD = "reload".freeze
	AUTO = "auto".freeze
	INDEX = "index".freeze
	INDEXED = "indexed".freeze
	READ = "read".freeze
	ASSIGN = "assign".freeze
	UNASSIGN = "unassign".freeze
	UPDATE = "update".freeze
	UPGRADE = "∆".freeze
	DOWNGRADE = "∇".freeze
	BATCH_UPDATE = "Update Selected".freeze

	def initialize(*param_values)
		@param_values = param_values
	end

	def matches?(request)
		@param_values.any?{|prm| request.params[:commit] == prm.to_s}
	end
end