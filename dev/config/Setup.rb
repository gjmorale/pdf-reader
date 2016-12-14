
module Setup

	module Debug

		def self.overview
			return @debug_overview ||= false
		end
		
		def self.overview= value
			@debug_overview = value
		end

	end

	# Bank document formats must match ARGV[0]
	module Format
		HSBC = "HSBC"
		MS = "MS"
		TEST = "test"
	end

	# Field text alignment
	# 8--1--2
	# | \|/ |
	# 7— + —3
	# | /|\ |
	# 6--5--4
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
			@@wildchar ||= Setup.bank.class::WILDCHAR
		end

		def self.date_format
			@@date_format ||= Setup.bank.class::DATE_FORMAT
		end

		def self.horizontal_search_range
			@@horizontal_search_range ||= Setup.bank.class::HORIZONTAL_SEARCH_RANGE
		end

		def self.vertical_search_range
			@@vertical_search_range ||= Setup.bank.class::VERTICAL_SEARCH_RANGE
		end

		def self.center_mass_limit
			@@center_mass_limit ||= Setup.bank.class::CENTER_MASS_LIMIT
		end
	end

	# Table specific constants
	module Table

		def self.offset
			@@offset ||= Setup.bank.class::TABLE_OFFSET
		end

		def self.header_orientation
			@@orientation ||= Setup.bank.class::HEADER_ORIENTATION
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
			puts "TEST BANK selected"
			@@bank = Test.new()
		when Format::HSBC
			puts "HSBC selected"
			@@bank = HSBC.new()
		when Format::MS
			puts "Morgan Stanley selected"
			@@bank = MorganStanley.new()
		end

	end

	def self.bank
		@@bank
	end

end

# Abstract bank class never to be instantiated
class Bank

	# Accounts to store information
	attr_accessor :accounts
	# Accounts to store information
	attr_accessor :positions

	# FINE TUNNING parameters:
	# Override in sub-classes for bank specific
	TABLE_OFFSET = 6
	HEADER_ORIENTATION = 8
	VERTICAL_SEARCH_RANGE = 5
	HORIZONTAL_SEARCH_RANGE = 15
	CENTER_MASS_LIMIT = 0.40
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
		raise NoMethodError, "Bank is an abstract class"
	end

	def to_arr(item, n)
		r = []
		n.times do |i|
			r << item
		end
		r
	end

	def print_results  file
		@positions.each do |p|
			file.write(p.print)
		end
	end

end