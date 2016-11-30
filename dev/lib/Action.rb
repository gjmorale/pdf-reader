# Action is an executable element to obtain
# or manipulate other field results
class Action

	# Recieves a block on instantiation
	def initialize block
		@block = block
	end

	# The block is executed when called upon
	# Because the block's scope was defined on
	# instantiation, it can perform operations
	# on local variables from field declaration
	# and the bank instance itself. So this class
	# is only a wrapper for a block to be executed
	# in a specific secuence.
	def execute reader
		@block.call
	end
end