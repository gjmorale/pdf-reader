class Sequence < ApplicationRecord
  belongs_to :tax, inverse_of: :sequences
  has_one :society, through: :tax
  has_one :bank, through: :tax
  has_many :statements, dependent: :destroy, inverse_of: :sequence

  before_validation :default_quantities
  validates :date, presence: true
  validates :quantity, presence: true
  validates_uniqueness_of :tax_id, scope: :date
  accepts_nested_attributes_for :statements
  validate :set_start_date

  def periodicity
  	@periodicity ||= tax.periodicity
  end

  def filter params
    query = statements
    query = query.joins(sequence: [tax: :society])
    params.filter query
  end

  def node_path status: :open
    "/sequences/#{id}?status=#{status.to_s}"
  end

  def progress
    statements.joins(:status).sum("statement_statuses.progress")/capacity
  end

  def recieved
    statements.size/capacity
  end

  def date_path
    date_s = "#{date.year}"
    date_s << "-#{date.month}"
    if periodicity == Tax::Periodicity::WEEKLY
      date_s << "-S#{date.week}"
    else
      date_s << "-#{date.day}"
    end
    date_s
  end

  def capacity
    total = statements.count
    if total < quantity
      quantity
    elsif total < quantity + optional
      total
    else
      quantity + optional
    end
  end

  def assign_all role
    statements.each do |statement|
      statement.assign_to(role)
    end
  end

  private

    def default_quantities
      self.quantity ||= tax.quantity
      self.optional ||= tax.optional
    end

    def set_start_date
      self.start_date ||= Tax.to_period_start date, periodicity
      errors.add(:start_date, "Undefined start date") unless self.start_date
    end

end
