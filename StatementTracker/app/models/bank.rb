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
		BLANK = "BLANK"
	end

	has_many :synonyms, as: :listable

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

	def reader_bank
		puts "FOLDER: #{self.folder_name}"
		case self.folder_name
		when Format::HSBC
			return HSBC.new()
		when Format::MS
			return MS.new()
		when Format::SEC
			return SEC.new()
		when Format::BC
			return BC.new()
		when Format::MON
			return MON.new()
		when Format::CORP
			return CrediCorp.new()
		when Format::PER
			return PER.new()
		when Format::BLANK
			return BLANK.new()
		else
			return nil
		end
	end

	private

		def default_synonyms
			self.synonyms.where(label: self.code_name).first_or_create
			self.synonyms.where(label: self.name).first_or_create
			self.synonyms.where(label: self.folder_name).first_or_create
		end
end
