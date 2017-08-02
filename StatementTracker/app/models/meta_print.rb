class MetaPrint < ApplicationRecord
  belongs_to :bank, required: false
  has_many :cover_prints

  validates :producer, presence: true, length: {minimum: 3}
  validates :creator, presence: true, length: {minimum: 3}
  validates_uniqueness_of :producer, scope: :creator
end
