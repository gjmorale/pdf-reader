class Dictionary < ApplicationRecord

  belongs_to :target, polymorphic: true, required: false
  has_many :dictionary_elements
  has_many :statements, :through => :dictionary_elements, :source => :element, :source_type => 'Statement'
  validates :identifier, presence: true, length: {minimum: 5}

  def invalid?
    @invalid ||= target.invalid?
  end

  def self.register element, value
  	dictionary = Dictionary.find_by(identifier: value)
  	#check_possible repeated elements and acceptance of element to dictionary
  	dictionary ||= Dictionary.create(identifier: value, target: nil)
  	#Return nil if dictionary is invalid
  	dictionary.dictionary_elements.create(element: element) if dictionary
  	return !!dictionary
  end
end
