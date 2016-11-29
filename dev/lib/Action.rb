class Action

	def initialize block
		@block = block
	end

	def execute reader
		@block.call
	end
end