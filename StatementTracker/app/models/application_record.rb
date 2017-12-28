class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

	def js_id
		"#{self.class.to_s.downcase}-#{self.id}"
	end
end

Date.class_eval do 
	def week
		(self.day-1)/7+1
	end
end