class Dictionary < ApplicationRecord

  belongs_to :target, polymorphic: true, required: false
  has_many :dictionary_elements
  has_many :statements, :through => :dictionary_elements, :source => :element, :source_type => 'Statement'
  validates :identifier, presence: true, length: {minimum: 5}, uniqueness: true

  def invalid?
    @invalid ||= target.invalid?
  end

  def self.register element, value
    puts "LOOKING FOR DIC WITH IDENTIFIER #{value}"
  	dictionary = Dictionary.find_by(identifier: value)
  	#check_possible repeated elements and acceptance of element to dictionary
  	dictionary ||= Dictionary.create(identifier: value, target: nil)
  	#Return nil if dictionary is invalid
    return nil unless dictionary and dictionary.valid?
    if element.dictionary_element
      element.dictionary_element.destroy
    end
  	dictionary.dictionary_elements.create(element: element) if dictionary
  	return !!dictionary
  end
end
