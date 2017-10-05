class SourcePath < ApplicationRecord
  belongs_to :tax, inverse_of: :source_paths

  validates :path, presence: true, uniqueness: true
  validate :valid_path

  def to_s
  	path
  end

  private

  	def valid_path
      self.path = "#{path}/" unless self.path[-1] == '/'
  		errors.add(:path, "Path doesn't exist") unless FileManager.exist? path
  	end

end
