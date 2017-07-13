class Statement < ApplicationRecord

  MAX_EQ_TEXT_LENGTH = 25

  belongs_to :sequence, required: false
  belongs_to :client, class_name: "Society"
  has_one :dictionary_element, :as =>:element
  has_one :dictionary, :through => :dictionary_element
  has_one :target, :through => :dictionary, source: 'target', source_type: 'Society'
  belongs_to :bank, required: false
  belongs_to :handler, required: false
  belongs_to :status, class_name: "StatementStatus"

  validates :file_hash, presence: true, uniqueness: true
  validate :integrity
  before_validation :default_status

  def assign_to value
    return nil unless self.handler_id.nil?
    return self.update(handler: value)
  end

  def unassign_handler
    self.handler = nil
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
    periodicity = nil
    if d_close and d_open
      delta = (d_close - d_open).to_i
      if delta > 31
        periodicity = Tax::ANNUAL
      elsif delta > 8
        periodicity = Tax::MONTHLY
      elsif delta > 1
        periodicity = Tax::WEEKLY
      else
          periodicity = Tax::DAILY
      end
    end
    return periodicity
  end

  def d_last
    return d_close || d_filed
  end

  def society
    if sequence and sequence.tax
      return sequence.tax.society
    elsif target and not dictionary.invalid?
      return target
    else
      return nil
    end
  end

  def if
    return nil unless self.sequence and self.sequence.tax_id
    self.sequence.tax.bank
  end

  def date
    date_hash = nil
    if self.sequence_id
      date_hash = self.sequence.date
    else
      date_hash = {} unless self.sequence
    end
    return date_hash
  end

  def find_tax society_id
    if periodicity
      puts "#{periodicity} #{society_id}"
      return Tax.find_by(bank: bank, society_id: society_id, periodicity: periodicity)
    else
      return Tax.find_by(bank: bank, society_id: society_id)
    end
  end

  def file
    return "DEBUG in file"
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
    return "DEBUG in set_raw"
    FileManager.get_raw file, raw_path
  end

  def renotice
    return "DEBUG in renotice"
    attrs = FileMeta.classify file if file?
    return self.assign_attributes attrs
  end

  def eq
    text = nil
    if self.dictionary
      text = self.dictionary.identifier
      if text.length > MAX_EQ_TEXT_LENGTH
        text = text[0, MAX_EQ_TEXT_LENGTH - 1]+'...'
      end
    end
    text
  end

  def progress
    self.status.progress
  end

  private

    def default_status
      self.status ||= StatementStatus.find_by(code: StatementStatus::NOTICED)
      return
    end

    def raw_path
      "#{self.file_hash[0..6]}"
    end

    def integrity
      if rank? :noticed
        errors.add(:file_hash,"File not found") unless file?
        errors.add(:file_hash,"Temp file not found") unless set_raw
      else
        errors.add(:status, "No status")
      end
      if rank? :index
        errors.add(:bank, "Bank not set") unless bank
        errors.add(:client, "Client not set") unless client
      end
      if rank? :indexed
        errors.add(:d_open, "Open date not set") unless d_open
        errors.add(:d_close, "Close date not set") unless d_close
        errors.add(:dictionary, "EQ not found or created") unless dictionary
        errors.add(:sequence, "Couldn't fit with a society") unless society
        errors.add(:sequence, "Doesn't belong to a sequence") unless sequence
        errors.add(:sequence, "Sequence is full") unless sequence.nil? or accepting?
      end
      if rank? :read
      end
      puts "ERRORS: #{errors.messages}" if errors.any?
    end

    def accepting?
      return false unless sequence
      !!(sequence.accepting? or sequence.statements.include? self)
    end

end
