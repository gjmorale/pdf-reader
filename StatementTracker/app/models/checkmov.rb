class Checkmov < ApplicationRecord
  belongs_to :society, inverse_of: :checkmovs

  validates :path, presence: true, uniqueness: true
  validate :valid_path

  def chrome_path user
    return '#' unless path and user
    esc_file = base_path.sub('#','%23')
    return "file://#{user.role.repo_path}/#{esc_file}"
  end

  private

  	def base_path
  		(Paths::CLIENTS+'/'+path).sub(Paths::DROPBOX,'')
  	end

  	def valid_path
  		errors.add(:path, "Path doesn't exist") unless FileManager.exist? path, base_path: Paths::CLIENTS
  		errors.add(:path, "Is not a Checkmov") unless path =~ /(.xls|.xlsx)$/i
  	end
end
