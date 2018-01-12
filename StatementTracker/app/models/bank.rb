class Bank < ApplicationRecord

	# Institutional document's formats must match ARGV[0]
	module Format
		HSBC = "HSBC"
		MS = "MS"
		SEC = "SEC"
		BC = "BC"
		MON = "MON"
		CORP = "CORP"
		PER = "PER"
	end

	has_many :synonyms, as: :listable, dependent: :destroy
	has_many :taxes, dependent: :destroy

	validates :code_name, presence: true, uniqueness: true
	validates :folder_name, presence: true, uniqueness: true

	after_create :default_synonyms

  	accepts_nested_attributes_for :synonyms, allow_destroy: true

	def to_s
		name
	end

	def index path
		dir = FileManager.get_raw_dir path
		FileReader.index reader_bank, dir
		raise #TODO: If un-noticed, delete method
	end

	def self.dictionary term
		#https://stackoverflow.com/questions/2220423/case-insensitive-search-in-rails-model
		syn = Synonym.find_by(listable_type: self.to_s, label: term.strip.titleize)
		return !!(syn)
	end

	def self.find_bank term
		#https://stackoverflow.com/questions/2220423/case-insensitive-search-in-rails-model
		#TODO: Synonim model ordered by name
		syn = Synonym.find_by(listable_type: self.to_s, label: term.strip.titleize)
		return syn.listable
	end

	def tax_included
		self.taxes.left_outer_joins(:society, sequences: [statements: :status])
	end

	def recieved date_params
		targets = tax_included
		query = date_params.filter targets, distinct: false
		query.size
	end

	def expected date_params
		targets = tax_included
		targets = date_params.filter_quantities targets
		targets.sum(&:q_expected)
	end

	def recieved_progress date_params
		targets = tax_included
		targets = date_params.filter_quantities targets
		total = targets.sum(&:q_expected)
		real_recieved = targets.map{|r| [r.q_recieved,r.q_expected].min}.reduce(:+)
		return 100 if total == 0
		real_recieved*100/total
	end

	def period_progress date_params
		n = expected(date_params)
		return 100 if n == 0
		targets = tax_included
		status = StatementStatus.arel_table	
		query = date_params.filter targets, distinct: false
		query = query.select(status[:progress].as("status_progress"))
		query.sum(&:status_progress)/n
	end

	private

		def default_synonyms
			self.synonyms.where(label: self.code_name.strip.titleize).first_or_create
			self.synonyms.where(label: self.name.strip.titleize).first_or_create
			self.synonyms.where(label: self.folder_name.strip.titleize).first_or_create
		end
end
