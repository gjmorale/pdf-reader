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
      puts "CHANGING FROM #{statement.status.code} TO #{new_status} #{from_sym new_status}"
      original_status = statement.status
      safe = false
      case new_status.to_sym
      when :noticed
        if statement.rank? :noticed
          yield
          statement.status = StatementStatus.find_by(code: NOTICED)
          sequence = statement.sequence
          statement.sequence = nil
          safe = statement.save
          sequence.destroy if sequence and safe and not sequence.statements.any?
        end
      when :index
        if statement.rank? :noticed
          yield
          statement.status = StatementStatus.find_by(code: INDEX)
          sequence = statement.sequence
          statement.sequence = nil
          safe = statement.save
          sequence.destroy if sequence and safe and not sequence.statements.any?
        end
      when :indexed
        if statement.rank? :index 
          yield
          statement.status = StatementStatus.find_by(code: INDEXED)
          if safe = statement.save
            if statement.dictionary
              statement.dictionary.target = statement.society
              statement.dictionary.save
            end
          end
        end
      when :read
        if statement.rank? :indexed
          yield
          statement.status = StatementStatus.find_by(code: READ)
        end
        safe = statement.save
      when :stage
        if statement.rank? :read
          yield
        end
        safe = false
      when :upload
        if statement.rank? :stage
          yield
        end
        safe = false
      when :archived
        #PRE-READING ITERATION
        if statement.rank? :indexed
          yield
          statement.status = StatementStatus.find_by(code: ARCHIVED)
          safe = statement.save?
        end
      end
      statement.status = original_status unless safe
      return safe
    end
end
