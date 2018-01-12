class Tax < ApplicationRecord

  module Periodicity
  	ANNUAL = "Annual"
  	MONTHLY = "Monthly"
  	WEEKLY = "Weekly"
  	DAILY = "Daily"

  	ALL = [
  		ANNUAL,
  		MONTHLY,
  		WEEKLY,
  		DAILY
  	]
  end

  has_many :sequences, dependent: :destroy, inverse_of: :tax
  has_many :statements, through: :sequences, inverse_of: :tax
  has_many :source_paths, dependent: :destroy, as: :sourceable

  belongs_to :bank
  belongs_to :society

  validates :periodicity, presence: true
  accepts_nested_attributes_for :sequences
  accepts_nested_attributes_for :source_paths, allow_destroy: true
  validates :source_paths, :length => { :minimum => 1 }

  def to_s
    "#{bank} - #{society}"
  end

  def self.to_period_end date, periodicity
    case periodicity
    when Periodicity::ANNUAL
      date.end_of_year
    when Periodicity::MONTHLY
      date.end_of_month
    when Periodicity::WEEKLY
      date.end_of_week
    when Periodicity::DAILY
      date
    end
  end

  def self.to_period_start date, periodicity
    case periodicity
    when Periodicity::ANNUAL
      date.beginning_of_year
    when Periodicity::MONTHLY
      date.beginning_of_month
    when Periodicity::WEEKLY
      date.beginning_of_week
    when Periodicity::DAILY
      date
    end
  end

  def filter params
    query = statements
    query = query.joins(sequence: [tax: :society])
    params.filter query
  end

  def node_path status: :open
    "/taxes/#{id}?status=#{status.to_s}"
  end

  def time_nodes params
    query = sequences
    query = query.joins(:society, :statements)
    params.filter query
  end

  def progress params
    return 100 if quantity == 0
    means = time_nodes(params).joins(statements: :status).group("sequences.id").sum("statement_statuses.progress")
    return 0 unless means.any?
    (means.inject(0){|t, m| t + m[1]}/(self.quantity*means.size)).to_i
  end

  def sequence_included
    self.sequences.left_outer_joins(statements: :status, tax: :society)
  end

  def sequence date_params
    date_params.filter(sequence_included).take
  end

  def dated_statements date_params
    seq = sequence date_params
    seq ? seq.statements : self.class.none
  end

  def expected date_params
    seq = sequence date_params
    seq ? seq.quantity : self.quantity
  end

  def recieved date_params
    dated_statements(date_params).size
  end

  def period_progress date_params
    ds = dated_statements(date_params)
    n = expected(date_params)
    return 100 if n == 0
    ds.sum(&:progress).to_f / expected(date_params)
  end

  def last_sequence
    statements.order(:d_filed).first
  end

  def self.reload date_from = nil, date_to = nil
    self.all.each do |tax|
      tax.reload date_from, date_to
    end
  end

  def reload date_from = Date.current.beginning_of_month, date_to = Date.current.end_of_month
    case periodicity
    when Periodicity::ANNUAL
      date_from = date_from.beginning_of_year + 6.month
      date_to = date_to.end_of_year + 6.month
    when Periodicity::MONTHLY
      date_from = date_from.end_of_month - 2.day
      date_to = date_to.end_of_month + 22.day
    when Periodicity::WEEKLY
      date_from = date_from.end_of_week
      date_to = date_to.end_of_week + 4.day
    when Periodicity::DAILY
      date_from = date_from
      date_to = date_to
    end

    source_paths.each do |source_path|
      if files = FileManager.load_from(source_path.path, date_from, date_to)
        files.each do |file|
          date = file[1]
          case periodicity
          when Periodicity::ANNUAL
            q_date = date.month <= 10 ? date.beginning_of_year - 1.day : date.end_of_year
          when Periodicity::MONTHLY
            q_date = date.day < 22 ? date.beginning_of_month - 1.day : date.end_of_month
          when Periodicity::WEEKLY
            q_date = date.wday <= 6 ? date.beginning_of_week - 1.day : date.end_of_week
          else
            q_date = date
          end
          if seq = sequences.where(date: q_date).first_or_create
            statement = Statement.new_from_file file[0]
            seq.statements << statement
            seq.save
          end
        end
      end
    end
  end

  def adjust
    q = self.quantity
    self.sequences.each do |seq|
      p = seq.quantity
      r = seq.statements.size
      if r > p
        seq.quantity = r
        seq.save
      end
      q = [p,r,q].max
    end
    self.quantity = q
    self.save
  end

  def close date_params
    self.quantity = 0
    self.active = false
    self.save
    if seq = self.sequence(date_params)
      seq.quantity = seq.statements.size
      seq.save
    end
  end

end
