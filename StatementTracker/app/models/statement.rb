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
      self.save
    end
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
      delta = (d_open-d_close).days
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
    return nil unless self.sequence and self.sequence.tax
    self.sequence.tax.bank
  end

  def date
    return nil unless self.sequence
    self.sequence.date
  end

  def find_tax society
    if periodicity
      return Tax.find_by(bank: bank, society: society, periodicity: periodicity)
    else
      return Tax.find_by(bank: bank, society: society)
    end
  end

  def file
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
    FileManager.get_raw file, raw_path
  end

  def eq_text
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
        errors.add(:hash,"File not found") unless file?
        errors.add(:hash,"Temp file not found") unless set_raw
      else
        errors.add(:status, "No status")
      end
      if rank? :index
        errors.add(:bank, "Bank not set") unless bank
        errors.add(:client, "Client not set") unless client
      end
      if rank? :indexed
        errors.add(:dictionary, "EQ not found or created") unless dictionary
        errors.add(:dictionary, "EQ doesn't point to a society") unless society
      end
      if rank? :read
        errors.add(:sequence, "Sequence not set") unless sequence
        errors.add(:sequence, "Sequence is full") unless sequence.accepting?
      end
      puts "POST INTEGRITY #{errors.inspect}"
    end

end
