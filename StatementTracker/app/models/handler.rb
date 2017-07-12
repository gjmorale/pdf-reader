class Handler < ApplicationRecord
	has_many :statements

	def index statements
		statements.each do |statement|
			StatementStatus.change_state :index, statement do
				owner, date = statement.bank.reader_bank.index statement.set_raw
				if date
					statement.d_close = date
					#statement.d_open = date #IMPLEMENT!
				end
				Dictionary.register(statement, owner)
			end
		end
	end

	def fit_in_seq statement, society, **date_hash
		#society.nil?
		StatementStatus.change_state :indexed, statement do
			#d_open, d_close = Tax.parse_date date_hash
			#statement.d_open = d_open if d_open
			#statement.d_close = d_close if d_close
			tax = statement.find_tax society
			statement.sequence = tax.fit statement if tax
		end
	end

	def to_s
		self.short_name
	end
end
