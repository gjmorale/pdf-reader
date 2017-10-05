class Synonym < ApplicationRecord
  belongs_to :listable, polymorphic: true

  validates :label, presence: true
  validates_uniqueness_of :label, scope: :listable_type
  validate :valid_label

  private

  	def valid_label
  		unless self.label and self.label =~ /[a-zA-Z]+/
  			self.errors.add(:label, "Invalid label")
  		else
  			self.label = self.label.strip.titleize
  		end
  	end

end
