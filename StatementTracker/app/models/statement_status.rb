class StatementStatus < ApplicationRecord

  	has_many :statements

  	def to_s
  		message
  	end

    def archived?
      !!(self == StatementStatus.all.order(code: :desc).first)
    end

    def self.group_by_status statements
      statements.sort_by(&:status).reverse.group_by(&:status)
    end

    def self.noticed
      StatementStatus.all.order(code: :asc).first
    end

    def noticed?
      !!(self == StatementStatus.all.order(code: :asc).first)
    end

    def self.next_status original_status
      StatementStatus.where("code > ?", original_status.code).order(code: :asc).first
    end

    def self.previews_status original_status
      StatementStatus.where("code < ?", original_status.code).order(code: :desc).first
    end
end
