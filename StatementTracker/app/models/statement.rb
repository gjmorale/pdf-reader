class Statement < ApplicationRecord

  MAX_EQ_TEXT_LENGTH = 25

  belongs_to :handler, required: false
  belongs_to :status, class_name: "StatementStatus"
  belongs_to :sequence

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
  end

  def assign_to value
    return nil unless self.handler_id.nil?
    return self.update(handler: value)
  end

  def unassign_handler
    self.handler = nil
    raise
    if FileManager.rm_raw raw_path
      return self.save
    end
    return false
  end

  def self.unassigned
    Statement.where(handler: nil)
  end

  def status? value
    value = StatementStatus.from_sym value
    !!(self.status.code == value)
  end

  def rank? value
    value = StatementStatus.from_sym value
    !!(self.status.code >= value)
  end

  def periodicity
    periodicity = Tax::MONTHLY
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

  def file
    raise
    real_file = FileManager.get_file path, file_hash
    if File.exist? real_file
      return real_file
    else
      if real_file
        raise IOError, "FILE WAS MOVED! IMPLEMENT CONTROL FOR THIS"
      end
    end
    return nil
  end

  def file?
    !!file
  end

  def set_raw
    raise
    FileManager.get_raw file, raw_path
  end

  def delete_raw
    raise
    #Check to return true if there is no raw data
    FileManager.rm_raw raw_path
  end

  def remove
    #remove raw and destroy self, check dependents
    raise
    attrs = FileMeta.classify file if file?
    return self.assign_attributes attrs
  end

  def progress
    self.status.progress
  end

  private

    def default_status
      self.status ||= StatementStatus.find_by(code: StatementStatus::NOTICED)
    end

    def raw_name
      raise # Set a more descriptive name
      "#{self.file_hash[0..8]}"
    end

    def remove_raw_data
      raise
      delete_raw
    end

    def integrity
      if rank? :noticed
        errors.add(:sequence, "Doesn't belong to a sequence") unless sequence
        errors.add(:sequence, "Sequence is full") unless accepting?
        unless rank? :archived
          errors.add(:file_hash, "Temp file not found") unless get_raw
          errors.add(:path, "Original file not found") unless file?
        end
      else
        errors.add(:status, "No status")
      end
      if rank? :archived
        errors.add(:file_name, "Unable to delete temp data") unless delete_raw
      end
      puts "STATEMENT #{self}\'s ERRORS: #{errors.messages}" if errors.any?
    end

    def accepting?
      return false unless sequence
      !!(sequence.accepting? or sequence.statements.include? self)
    end



end
