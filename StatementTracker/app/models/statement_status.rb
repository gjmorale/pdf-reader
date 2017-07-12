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

    def self.change_state new_status, statement

      case new_status
      when :noticed
        if statement.rank? :noticed
          yield
        end
        if statement.file? and
          statement.set_raw
          statement.status = StatementStatus.find_by(code: NOTICED)
          return statement.save
        end
      when :index
        if statement.rank? :noticed
          yield
        end
        if statement.bank_id and
          statement.client_id
          statement.status = StatementStatus.find_by(code: INDEX)
          return statement.save
        end
      when :indexed
        if statement.rank? :index 
          yield
        end
        if statement.society
          statement.status = StatementStatus.find_by(code: INDEXED)
          return statement.save
        end
      when :read
        if statement.rank? :indexed
          yield
        end
        if statement.sequence
          statement.status = StatementStatus.find_by(code: READ)
          return statement.save
        end
      when :stage
        if statement.rank? :read
          yield
        end
        return false
      when :upload
        if statement.rank? :stage
          yield
        end
        return false
      when :archived
        if statement.rank? :upload
          yield
        end
        return false
      else
        false
      end

    end
end
