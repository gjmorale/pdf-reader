class Handler < ApplicationRecord
	has_many :statements
	has_one :user, as: :role

	def to_s
		self.short_name
	end

	def unassign_all
    statements.each do |statement|
      statement.unassign_handler
    end
  end
end
