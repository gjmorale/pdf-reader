class SourcePath < ApplicationRecord
  belongs_to :sourceable, polymorphic: true, required: false

  validates :path, presence: true, uniqueness: true
  validate :valid_path

  def to_s
  	path
  end

  private

  	def valid_path
      self.path = "#{path}/" unless self.path[-1] == '/'
      errors.add(:path, "Path doesn't exist") unless FileManager.exist? self.path
  		raise unless FileManager.exist? self.path
  	end

end
