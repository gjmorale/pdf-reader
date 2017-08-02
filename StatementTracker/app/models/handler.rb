class Handler < ApplicationRecord
	has_many :statements
	has_one :user, as: :role

	def auto statement
		unless statement.rank? :index
			return unless index statement 
			statement.reload
		end
		unless statement.rank? :indexed
			return unless fit_in_seq statement 
			statement.reload
		end
		unless statement.rank? :read
			return unless read statement
		end 
	end

	def renotice statement
		puts "#{statement.file_name} CHANGING TO NOTICED"
		StatementStatus.change_state :noticed, statement do
			statement.renotice
		end
	end

	def index statement, bank_id = nil
		puts "#{statement.file_name} CHANGING TO INDEX WITH BANK_ID #{bank_id}"
		StatementStatus.change_state :index, statement do
			statement.bank_id = bank_id if bank_id
			date = nil
			date = statement.d_close || statement.d_filed || Date.current-1.month
			owner, date_i, date_f = statement.bank.reader_bank.index statement.set_raw
			statement.d_open = date_i
			statement.d_close = date_f
			dic = Dictionary.register(statement, owner)
			puts "WAS A DICTIONARY FOUND OR CREATED? #{!!dic}"
		end
	end

	def fit_in_seq statement, society_id = nil, open_date = nil, close_date = nil
		puts "#{statement.file_name} CHANGING TO INDEXED WITH SOCIETY #{society_id}"
		#society.nil?
		StatementStatus.change_state :indexed, statement do
			statement.d_open = open_date if open_date
			statement.d_close = close_date if close_date
			society_id ||= statement.society.id if statement.society
			puts "SOCIETY #{society_id}"
			puts statement.inspect
			tax = statement.find_tax society_id
			puts "FOUND #{tax ? tax.society.name : 'NOT'}"
			if tax
				statement.sequence = tax.fit statement 
			else
				statement.sequence = nil
			end
		end
	end

	def read statement
		StatementStatus.change_state :read, statement do 
			#statement.bank.reader_bank.read statement.set_raw
		end
	end

	def to_s
		self.short_name
	end

	def name
		user.name if user
	end
end
