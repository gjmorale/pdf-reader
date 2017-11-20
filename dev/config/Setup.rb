module Setup

	module Debug

		def self.overview
			return @debug_overview ||= false
		end
		
		def self.overview= value
			@debug_overview = value
		end

	end

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

	# Field text alignment
	# 8——1——2
	# | \|/ |
	# 7— + —3
	# | /|\ |
	# 6——5——4
	module Align
		TOP = 			1
		TOP_RIGHT = 	2
		RIGHT = 		3
		BOTTOM_RIGHT = 	4
		BOTTOM = 		5
		BOTTOM_LEFT = 	6
		LEFT = 			7
		TOP_LEFT = 		8
	end

	# Reading parameters taken from specific bank
	# or default. Folows ruby convention to store
	# constants.
	module Read

		def self.reset
			@@wildchar = nil
			@@date_format = nil
			@@horizontal_search_range = nil
			@@vertical_search_range = nil
			@@center_mass_limit = nil
			@@text_expand = nil
		end

		def self.wildchar
			@@wildchar ||= Setup.inst.class::WILDCHAR
		end

		def self.date_format
			@@date_format ||= Setup.inst.class::DATE_FORMAT
		end

		def self.horizontal_search_range
			@@horizontal_search_range ||= Setup.inst.class::HORIZONTAL_SEARCH_RANGE
		end

		def self.vertical_search_range
			@@vertical_search_range ||= Setup.inst.class::VERTICAL_SEARCH_RANGE
		end

		def self.vertical_search_range= value
			@@vertical_search_range = value
		end

		def self.center_mass_limit
			@@center_mass_limit ||= Setup.inst.class::CENTER_MASS_LIMIT
		end

		def self.text_expand
			@@text_expand ||= Setup.inst.class::TEXT_EXPAND
		end
	end

	# Table specific constants
	module Table

		def self.reset
			@@global_offset = nil
			@@offset = nil
			@@orientation = nil
			@@safe_zone = nil
			@@header_offset = nil
		end

		def self.global_offset
			@@global_offset ||= Setup.inst.class::GLOBAL_OFFSET
		end

		def self.header_offset
			@@header_offset ||= Setup.inst.class::HEADER_OFFSET
		end

		def self.offset
			@@offset ||= Setup.inst.class::TABLE_OFFSET
		end

		def self.header_orientation
			@@orientation ||= Setup.inst.class::HEADER_ORIENTATION
		end

		def self.safe_zone
			@@safe_zone ||= Setup.inst.class::SAFE_ZONE
		end
	end

	# General data types in documents
	module Type
		PERCENTAGE = 	1
		AMOUNT = 		2
		INTEGER = 		3
		FLOAT = 		4
		CURRENCY = 		5
		ASSET = 		6
		LABEL = 		7
		DATE = 			8
		BLANK = 		9
	end

	# Sets up the specific bank format to be loaded
	def self.set_manual_enviroment(format)
		case format
		when Format::HSBC
			return HSBC
		when Format::MS
			return MS
		when Format::SEC
			return SEC
		when Format::BC
			return BC
		when Format::MON
			return MON
		when Format::CORP
			return CrediCorp
		when Format::PER
			return PER
		else
			return nil
		end
	end

	# Sets up the specific bank format to be loaded
	def self.set_enviroment(format, in_path, out_path)
		reset
		n = 24 - format::LEGACY.length
		trail = ""
		n.times do |i|
			char = i%2 == 0 ? "¨" : "-"
			trail << char
		end
		puts "\n                                      ".underlined
		puts "¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-"
		puts "¨-¨-¨-¨-¨-¨-¨-#{format::LEGACY}#{trail}".faint	
		puts "¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-".underlined
		@@institution = format.new()
		@@institution.set_paths(in_path, out_path)
	end

	def self.inst
		@@institution
	end

	def self.reset
		@@institution = nil
		Read.reset
		Table.reset
	end

end

# Abstract bank class never to be instantiated
class Institution

	# FINE TUNNING parameters:
	# Override in sub-classes for bank specific
	GLOBAL_OFFSET = [0,0,0,0]
	TABLE_OFFSET = 6
	HEADER_OFFSET = 1
	HEADER_ORIENTATION = 8
	VERTICAL_SEARCH_RANGE = 5
	HORIZONTAL_SEARCH_RANGE = 15
	CENTER_MASS_LIMIT = 0.40
	TEXT_EXPAND = 0.5
	SAFE_ZONE = 0
	WILDCHAR = '¶'
	DATE_FORMAT = '\d\d\/\d\d\/\d\d\d\d'

	# Regex format for a specific type.
	# bounded: if it should add start and end of text
	def get_regex(type, bounded = true)
		return Regexp.new('^'<<regex(type)<<'$') if bounded
		return Regexp.new(regex(type))
	end

	def set_paths in_path, out_path
		@in_path = in_path
		@out_path = out_path
	end

	def prerun out
		# Override for output preparation
	end

	# Main method be executed
	def run files
		files = files.map{|f| "#{@in_path}/#{dir}/#{f}"}
		prerun "#{@out_path}/#{dir}"
		files.each do |file|
			dir_path = File.dirname(file)
			dir_name = dir_path[dir_path.rindex('/')+1..-1]
			file_name = file[file.rindex('/')+1..-1]
			puts "\n                                      ".underlined
			print  "~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,".underlined
			puts " - #{file_name}"
				analyse_position file
			begin
			rescue StandardError => e
				puts e.to_s.red
			end
			unless File.exist? "#{@out_path}/#{dir_name}"
				Dir.mkdir("#{@out_path}/#{dir_name}")
			end
			pre_print
			out = "#{@out_path}/#{dir_name}/#{file_name}_pos.csv"
			print_pos out
			out = "#{@out_path}/#{dir_name}/#{file_name}_mov.csv"
			print_mov out
		end
	end

	# Method to index files instead of full reading
	def index files
		files = files.map{|f| "#{@in_path}/#{dir}/#{f}"}
		files.each do |file|
			dir_path = File.dirname(file)
			dir_name = dir_path[dir_path.rindex('/')+1..-1]
			file_name = file[file.rindex('/')+1..-1]
			puts "                                      ".underlined
			print "-.,-´`-.,-´`-.,-´`-.,-´`-.,-´`-.,-´`-.".underlined
			puts " - #{file_name}"
				owner, date = analyse_index file
			begin
				puts "#{legacy_code} : #{owner}"
			rescue StandardError => e
				puts e.to_s.red
			end
		end
		puts "                                      ".underlined
		puts "¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-¨-".underlined
	end

	def to_number str
		if str.is_a? Multiline
			str.strings.each do |line| 
				line.strip! unless line.empty?
				unless line.nil? or line.empty?
					str = line
					break
				end
			end
		end
		return 0.0 if str.nil? or str.empty?
		str = str.strip
		str = str.delete('$')
		str = str.delete(',')
		negative = (str.match /\(\$?\d+([.,]\d+)?\)/)
		str = str.delete('(')
		str = str.delete(')')
		str = str.delete('ST')
		str = str.delete('LT')
		if str == '—' or str == Result::NOT_FOUND
			return 0.0
		else
			num = str.to_f
			num = num*(-1) if negative
			num
		end
	end

	def to_arr(item, n)
		r = []
		n.times do |i|
			r << item
		end
		r
	end
	
	def check acumulated, stated
		if stated == 0
			puts "UNABLE TO CHECK #{acumulated}".yellow
			return
		end
		delta = acumulated - stated
		delta = delta * delta
		if delta > 1
			puts "CHECK #{acumulated.round(2)} - #{stated}".red
			#raise CustomError::NO_MATCH
		else
			puts "CHECK #{acumulated.round(2)} - #{stated}".green
		end
	end

	def clone_it field
		return nil if field.nil?
		if field.is_a? Array
			return field.map{|f| f.clone}
		else
			return field.clone
		end
	end

end