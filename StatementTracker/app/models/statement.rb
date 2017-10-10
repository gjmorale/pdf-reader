class Statement < ApplicationRecord

  MAX_EQ_TEXT_LENGTH = 25

  belongs_to :handler, required: false
  belongs_to :status, class_name: "StatementStatus"
  belongs_to :sequence, inverse_of: :statements
  has_one :tax, through: :sequence, inverse_of: :statements
  has_one :bank, through: :tax
  has_one :society, through: :tax

  validates :file_hash, presence: true, uniqueness: true
  validate :integrity
  before_validation :default_status
  before_destroy :remove_raw_data

  def self.new_from_file source_file
    statement = Statement.new
    statement.path = source_file
    statement.file_hash = FileManager.digest_this source_file
    statement.file_name = File.basename(source_file).gsub(/\..+$/,'')
    statement.d_filed = DateTime.now
    statement
  end

  def update_from_form params
    if params[:file_name] != file_name
      file_name = params[:file_name]
    end
    target_bank = params[:bank_id] == bank.id.to_s ? nil : Bank.find(params[:bank_id].to_i)
    target_society = params[:society_id] == society.id.to_s ? nil : Society.find(params[:society_id].to_i)
    target_periodicity = params[:periodicity] == tax.periodicity ? nil : params[:periodicity]
    target_tax = nil
    if target_bank or target_society or target_periodicity
      target_tax = Tax.find_by(
        society: target_society || society, 
        bank: target_bank || bank, 
        periodicity: target_periodicity || periodicity
      )
    end
    
    target_date = Date.new(params["date(1i)"].to_i,params["date(2i)"].to_i,params["date(3i)"].to_i)
    target_date = Tax.to_period_end target_date, target_periodicity || periodicity
    target_date = nil if target_date == sequence.date
    if target_tax or target_date
      target_sequence = Sequence.where(
        tax: target_tax || tax,
        date: target_date || date
      ).first_or_create
    end
    self.sequence = target_sequence if target_sequence
    return self.save
  end

  def upgrade
    self.status = StatementStatus.next_status self.status
    self.save
  end

  def downgrade
    self.status = StatementStatus.previews_status self.status
    self.save
  end

  def assign_to value
    return nil unless self.handler_id.nil?
    return self.update(handler: value)
  end

  def unassign_handler
    self.handler = nil
    if FileManager.rm_raw raw_name
      return self.save
    end
    return false
  end

  def periodicity
    periodicity = tax.periodicity
  end

  def d_last
    return d_close || d_filed
  end

  def society
    self.sequence.tax.society
  end

  def if
    self.sequence.tax.bank
  end

  def date
    self.sequence.date
  end

  def check_file
    FileManager.get_file path, file_hash
  end

  def file
    real_file = check_file
    if real_file and real_file != self.path
      self.path = real_file
      self.save
      self.reload
    end
    return self.path
  end

  def chrome_path user
    return '#' unless file?
    esc_file = self.file.sub('#','%23')
    return "file://#{user.role.repo_path}/#{esc_file}"
  end

  def file?
    !!(self.path = check_file)
  end

  def raw?
    return true #DEBUG
  end

  def set_raw
    raise
    FileManager.get_raw file, raw_name
  end

  def progress
    self.status.progress
  end

  def node_path status: :open
    "/statements/#{id}?status=#{status.to_s}"
  end

  private

    def default_status
      self.status ||= StatementStatus.noticed
    end

    def raw_name
    # Set a more descriptive name
      "#{self.file_hash[0..8]}"
    end

    def remove_raw_data
      return true #DEBUG
      FileManager.rm_raw raw_path
    end

    def integrity
      if status.nil?
        errors.add(:status, "No status")
      else
        errors.add(:sequence, "Doesn't belong to a sequence") unless sequence
        unless status.archived?
          errors.add(:file_hash, "Temp file not found") unless raw?
          errors.add(:path, "Original file not found") unless file?
        end
      end
      if status.archived?
        errors.add(:file_name, "Unable to delete temp data") unless remove_raw_data
      end
    end

end
