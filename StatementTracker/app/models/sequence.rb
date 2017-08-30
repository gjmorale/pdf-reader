class Sequence < ApplicationRecord
  belongs_to :tax
  has_one :society, through: :tax
  has_one :bank, through: :tax
  has_many :statements, dependent: :destroy

  validates_uniqueness_of :tax_id, scope: [:year,:month,:week,:day]
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

end
