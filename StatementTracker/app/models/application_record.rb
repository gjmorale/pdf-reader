class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

	def js_id
		"#{self.class.to_s.downcase}-#{self.id}"
	end
end
