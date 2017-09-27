class Sequence < ApplicationRecord
  belongs_to :tax
  has_one :society, through: :tax
  has_one :bank, through: :tax
  has_many :statements, dependent: :destroy

  before_validation :default_quantities
  validates :date, presence: true
  validates :quantity, presence: true
  validates_uniqueness_of :tax_id, scope: :date
  accepts_nested_attributes_for :statements

  def periodicity
  	tax.periodicity
  end

  def accepting?
    statements.count < tax.quantity + tax.optional
  end

  def filter params
    query = statements
    query = query.joins(sequence: [tax: :society])
    params.filter query
  end

  def progress
    statements.joins(:status).sum("statement_statuses.progress")/capacity
  end

  def date_path
    date_s = "#{date.year}"
    date_s << "-#{date.month}"
    if periodicity == Tax::Periodicity::WEEKLY
      date_s << " Temporal #{date.week}"
    else
      date_s << "-#{date.day}"
    end
    date_s
  end

  def capacity
    total = statements.count
    if total < tax.quantity
      tax.quantity
    elsif total < tax.quantity + tax.optional
      total
    else
      tax.quantity + tax.optional
    end
  end

  def self.clean_up
    Self.all.joins(:statements).where(statements: {sequence_id: nil})
  end

  private

    def default_quantities
      self.quantity ||= tax.quantity
      self.optional ||= tax.optional
    end

end
