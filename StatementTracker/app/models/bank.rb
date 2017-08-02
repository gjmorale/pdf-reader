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

	validates :code_name, presence: true, uniqueness: true
	validates :folder_name, presence: true, uniqueness: true

	def to_s
		name
	end

	def index path
		dir = FileManager.get_raw_dir path
		FileReader.index reader_bank, dir
		raise #TODO: If un-noticed, delete method
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
end
