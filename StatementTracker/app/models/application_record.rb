class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  extend ConsoleLogger
  #Refactor to move inside ConsoleLogger
  def logs **args
  	self.class.logs args
  end
  def logp **args
  	self.class.logp args
  end
  

	def js_id
		"#{self.class.to_s.downcase}-#{self.id}"
	end
end
