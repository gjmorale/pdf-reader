class Sequence < ApplicationRecord
  belongs_to :tax
  has_one :society, through: :tax
  has_one :bank, through: :tax
  has_many :statements, dependent: :nullify

  validates_uniqueness_of :tax_id, scope: [:year,:month,:week,:day]


  def periodicity
  	tax.periodicity
  end

  def accepting?
    statements.count < tax.quantity
  end

  def date_path
  	case periodicity
  	when Tax::ANNUAL
  		return year
  	when Tax::MONTHLY
  		return [year, month].join('/')
  	when Tax::WEEKLY
  		return [year, month, (week)*7].join('/')
  	when Tax::DAILY
  		return [year, month, day].join('/')
  	end
  end

  def path
  	return "#{tax.path}/#{date_path}/#{bank.folder_name}"
  end

  def date
    hash_date = {}
    hash_date[:year] = self.year
    hash_date[:month] = self.month
    hash_date[:week] = self.week
    hash_date[:day] = self.day
    return hash_date
  end

  def filter params
    query = statements
    query = query.joins(sequence: [tax: :society])
    params.filter query
  end

  def progress
    statements.joins(:status).sum("statement_statuses.progress")/tax.quantity
  end

end
