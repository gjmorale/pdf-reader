class StatementStatus < ApplicationRecord

  	has_many :statements

  	def to_s
  		message
  	end

    def archived?
      !!(self == StatementStatus.all.order(code: :desc).first)
    end

    def self.group_by_status statements
      aux = self.joins("LEFT JOIN (#{statements.to_sql}) AS stms ON stms.status_id = statement_statuses.id")
      aux = aux.order(code: :desc).select("stms.id AS statement_id, statement_statuses.*")
      statuses = {}
      aux.each do |r|
        statuses[r] = [] unless statuses.has_key? r
        statuses[r] << Statement.find(r.statement_id) unless r.statement_id.nil?
      end
      statuses
    end

    def self.noticed
      StatementStatus.all.order(code: :asc).first
    end

    def noticed?
      self == StatementStatus.noticed
    end

    def self.next_status original_status
      StatementStatus.where("code > ?", original_status.code).order(code: :asc).first
    end

    def self.previews_status original_status
      StatementStatus.where("code < ?", original_status.code).order(code: :desc).first
    end
end
