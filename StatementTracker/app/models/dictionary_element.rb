class DictionaryElement < ApplicationRecord
  belongs_to :element, polymorphic: true
  belongs_to :dictionary
  validates_uniqueness_of :element_id, scope: :element_type
end
