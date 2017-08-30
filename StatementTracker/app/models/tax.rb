class Tax < ApplicationRecord
	has_many :sequences, dependent: :destroy
  has_many :statements, through: :sequences, inverse_of: :taxes

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

  validates_uniqueness_of :society_id, scope: :bank_id

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
      date_from = Date.new(date_from.year,1,1)
      date_to = Date.new(date_to.year+1,6,1)
    when Periodicity::MONTHLY
      date_from = Date.new(date_from.year,date_from.month,-5)
      if date_to.month == 12
        date_to = Date.new(date_to.year+1,1,22)
      else
        date_to = Date.new(date_to.year,date_to.month+1,22)
      end
    end
    files = FileManager.load_from source_path, date_from, date_to
    return unless files
    files.each do |file|
      date = File.mtime(file).to_date
      params = {}
      case periodicity
      when Periodicity::ANNUAL
        params[:year] = date.year
        params[:year] = date.year-1 if date.month <= 10
      when Periodicity::MONTHLY
        params[:year] = date.year
        params[:month] = date.month
        if date.day < 22
          if date.month == 1
            params[:year] = date.year-1
            params[:month] = 12
          else
            params[:month] = date.month-1
          end
        end
      end
      seq = sequences.where(params).first_or_create
      return unless seq
      statement = Statement.new_from_file file.gsub(Paths::DROPBOX,'')
      seq.statements << statement
      seq.save
    end
  end

end
