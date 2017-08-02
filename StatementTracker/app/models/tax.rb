class Tax < ApplicationRecord
	has_many :sequences, dependent: :destroy
  has_many :statements, through: :sequences

	ANNUAL = "Annual"
	MONTHLY = "Monthly"
	WEEKLY = "Weekly"
	DAILY = "Daily"

	PERIODICITIES = [
		ANNUAL,
		MONTHLY,
		WEEKLY,
		DAILY
	]

  belongs_to :bank
  belongs_to :society

  validates_uniqueness_of :society_id, scope: :bank_id

  def fit statement
  	hash = Tax.parse_date statement.d_open, statement.d_close
  	seq = self.sequences.find_by(hash) || self.sequences.build(hash)
    return seq
  end

  def path
    "#{society.path}"
  end

  def self.to_date **date
    open = close = nil
    date.each{|key,value| value = value.to_i}
    if date[:year] != 0
      year = date[:year]
      if date[:month] != 0
        open_month = close_month = date[:month]
      else
        open_month = 1
        close_month = 12
      end
      limit = Time.days_in_month close_month, year
      if date[:day] != 0
        open_day = close_day = date[:day]
      elsif date[:week] != 0 and date[:week] <= 5
        open_day = (date[:week] - 1)*7
        close_day = [(date[:week])*7, limit].min
      else
        open_day = 1
        close_day = limit
      end
      open_s = "#{open_day}-#{open_month}-#{year}"
      close_s = "#{close_day}-#{close_month}-#{year}"
      open = Date.strptime(open_s, "%d-%m-%Y")
      close = Date.strptime(close_s, "%d-%m-%Y")
    end
    return [open, close]
  end

  def self.parse_date open, close
    open ||= close
    date = {year: 0, month: 0, week: 0, day: 0}
    delta = (close-open).to_i
    date[:year] = open.year
    if delta <= 31
      date[:month] = open.month
      if delta <= 1
        date[:day] = close.day
      elsif delta <= 7
        date[:week] = (close.day/7+1)
      end
    end
    return date
  end

  def filter params
    query = statements
    query = query.joins(sequence: [tax: :society])
    puts query
    params.filter query
  end

  def time_nodes params
    query = sequences
    query = query.joins(:society, :statements)
    params.filter query
  end

  def progress params
    means = time_nodes(params).joins(statements: :status).group("sequences.id").sum("statement_statuses.progress")
    return 0 unless means.any?
    (means.map{|m| m[1].to_f}.inject{|t, m| t+(m)}/(quantity*means.size)).to_i
  end

end
