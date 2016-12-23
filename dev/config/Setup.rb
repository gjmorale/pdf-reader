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
		TEST = "TEST"
		COLMENA = "COLMENA"
		CONSALUD = "CONSALUD"
		CRUZBLANCA = "CRUZBLANCA"
		MASVIDA = "MASVIDA"
		VIDATRES = "VIDA3"
		BANMEDICA = "BANMEDICA"
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

		def self.center_mass_limit
			@@center_mass_limit ||= Setup.inst.class::CENTER_MASS_LIMIT
		end

		def self.text_expand
			@@text_expand ||= Setup.inst.class::TEXT_EXPAND
		end
	end

	# Table specific constants
	module Table

		def self.global_offset
			@@global_offset ||= Setup.inst.class::GLOBAL_OFFSET
		end

		def self.offset
			@@offset ||= Setup.inst.class::TABLE_OFFSET
		end

		def self.header_orientation
			@@orientation ||= Setup.inst.class::HEADER_ORIENTATION
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
	end

	module AccType
		FIXED_INCOME = 			1
		EQUITY_MUTUAL_FUND = 	2
	end

	# Sets up the specific bank format to be loaded
	def self.set_enviroment(format)
		case format
		when Format::TEST
			puts "TEST selected"
			@@institution = Test.new()
		when Format::HSBC
			puts "HSBC selected"
			@@institution = HSBC.new()
		when Format::MS
			puts "Morgan Stanley selected"
			@@institution = MorganStanley.new()
		when Format::COLMENA
			puts "Colmena selected"
			@@institution = Colmena.new()
		when Format::CONSALUD
			puts "Consalud selected"
			@@institution = Consalud.new
		when Format::CRUZBLANCA
			puts "Cruz Blanca selected"
			@@institution = CruzBlanca.new
		when Format::MASVIDA
			puts "Más Vida selected"
			@@institution = MasVida.new
		when Format::VIDATRES
			puts "Vida Tres selected"
			@@institution = VidaTres.new
		when Format::BANMEDICA
			puts "Banmedica selected"
			@@institution = Banmedica.new
		else
			puts "Wrong input, try again or CTRL + C to exit"
			return false
		end
	end

	def self.inst
		@@institution
	end

end

# Abstract bank class never to be instantiated
class Institution

	# FINE TUNNING parameters:
	# Override in sub-classes for bank specific
	GLOBAL_OFFSET = [0,0,0,0]
	TABLE_OFFSET = 6
	HEADER_ORIENTATION = 8
	VERTICAL_SEARCH_RANGE = 5
	HORIZONTAL_SEARCH_RANGE = 15
	CENTER_MASS_LIMIT = 0.40
	TEXT_EXPAND = 0.5
	WILDCHAR = '¶'
	DATE_FORMAT = '\d\d\/\d\d\/\d\d\d\d'

	# Regex format for a specific type.
	# bounded: if it should add start and end of text
	def get_regex(type, bounded = true)
		return Regexp.new('^'<<regex(type)<<'$') if bounded
		return Regexp.new(regex(type))
	end

	# Method to be overriden and executed
	def run 
		files = Dir["in/#{dir}/*"]
		files.each do |file|
			dir_path = File.dirname(file)
			dir_name = dir_path[dir_path.rindex('/')+1..-1]
			file_name = file[file.rindex('/')+1..-1]
			puts "\n***************************************** - #{file_name}\n"
			analyse_position file
			unless File.exist? "out/#{dir_name}"
				Dir.mkdir("out/#{dir_name}")
			end
			out = File.open("out/#{dir_name}/#{file_name}.csv",'w')
			print_results out
		end
		puts "\n*****************************************\n"
	end

	def to_number str
		str = str.inspect if str.is_a? Multiline
		str = str.strip
		str = str.delete('$')
		str = str.delete(',')
		negative = (str.include? '(' and str.include? ')')
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
		delta = acumulated - stated
		delta = delta * delta
		if delta > 1
			puts "CHECK #{acumulated.round(2)} - #{stated}".red
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