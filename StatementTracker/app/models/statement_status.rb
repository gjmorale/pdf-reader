class StatementStatus < ApplicationRecord

    NOTICED   = 110
    INDEX     = 120
    INDEXED   = 130
    READ      = 140
    STAGE     = 150
    UPLOAD    = 160
  	ARCHIVED  = 170

    STATUSES = [
      NOTICED,
      INDEX,
      INDEXED,
      READ,
      STAGE,
      UPLOAD,
      ARCHIVED
    ]

  	has_many :statements

  	def to_s
  		message
  	end

  	def self.from_sym value
      return nil unless value and not value.empty? 
      value = value.to_sym if value.is_a? String
  		case value
  		when :noticed
  			NOTICED
      when :index
        INDEX
      when :indexed
        INDEXED
      when :read
        READ
      when :stage
        STAGE
  		when :upload
  			UPLOAD
      when :archived
        ARCHIVED
  		else
  			nil
  		end
  	end

    def self.message code
      StatementStatus.find_by(code: code).message
    end
end
