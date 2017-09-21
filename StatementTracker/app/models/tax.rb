class Tax < ApplicationRecord
	has_many :sequences, dependent: :destroy
  has_many :statements, through: :sequences, inverse_of: :tax

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

  belongs_to :bank
  belongs_to :society

  validates :periodicity, presence: true
  validates :source_path, presence: true, uniqueness: true
  validate :source_path_exists

  def self.to_period_end date, periodicity
    case periodicity
    when Periodicity::ANNUAL
      Date.new(date.year,-1,-1)
    when Periodicity::MONTHLY
      Date.new(date.year,date.month,-1)
    when Periodicity::WEEKLY
      Date.new(date.year,date.month,date.day).next_week(:sunday)
    when Periodicity::DAILY
      Date.new(date.year,date.month,date.day)
    end
  end

  def self.to_period_start date, periodicity
    case periodicity
    when Periodicity::ANNUAL
      Date.new(date.year,1,1)
    when Periodicity::MONTHLY
      Date.new(date.year,date.month,1)
    when Periodicity::WEEKLY
      Date.new(date.year,date.month,date.day).beginning_of_week
    when Periodicity::DAILY
      Date.new(date.year,date.month,date.day)
    end
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

  def self.reload date_from = nil, date_to = nil
    self.all.each do |tax|
      tax.reload date_from, date_to
    end
  end

  def reload date_from = Date.new(2017,4,1), date_to = Date.current
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
    when Periodicity::WEEKLY
      date_from = date_from + 1.day
      date_to = date_from + 1.day
    end

    if files = FileManager.load_from(source_path, date_from, date_to)
      files.each do |file|
        date = File.mtime(file).to_date
        case periodicity
        when Periodicity::ANNUAL
          q_date = date.month <= 10 ? date.beginning_of_year - 1.day : date.end_of_year
        when Periodicity::MONTHLY
          q_date = date.day < 22 ? date.beginning_of_month - 1.day : date.end_of_month
        when Periodicity::WEEKLY
          q_date = date.wday <= 6 ? date.beginning_of_week - 1.day : date.end_of_week
        else
          q_date = date - 1.day
        end
        if seq = sequences.where(date: q_date).first_or_create
          statement = Statement.new_from_file file.gsub(Paths::DROPBOX,'')
          seq.statements << statement
          seq.save
        end
      end
    end
  end

  private

    def source_path_exists
      errors.add(:source_path, "Invalid source path") unless Dir.exist? Paths::DROPBOX + "/" + source_path
    end

end
