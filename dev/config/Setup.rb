
module Setup

	module Format
		HSBC = "HSBC"
		TEST = "test"
	end

	module Read
		VERTICAL_SEARCH_RANGE = 30
		HORIZONTAL_SEARCH_RANGE = 15
		CENTER_MASS_LIMIT = 0.40
		WILDCHAR = '¶'
		DATE_FORMAT = '\d\d\/\d\d\/\d\d\d\d'

		def self.wildchar
			@@wildchar = Setup.bank.class::WILDCHAR
			@@wildchar ||= WILDCHAR
		end

		def self.date_format
			@@date_format = Setup.bank.class::DATE_FORMAT
			@@date_format ||= DATE_FORMAT
		end

		def self.horizontal_search_range
			@@horizontal_search_range = Setup.bank.class::HORIZONTAL_SEARCH_RANGE
			@@horizontal_search_range ||= HORIZONTAL_SEARCH_RANGE
		end

		def self.vertical_search_range
			@@vertical_search_range = Setup.bank.class::VERTICAL_SEARCH_RANGE
			@@vertical_search_range ||= VERTICAL_SEARCH_RANGE
		end

		def self.center_mass_limit
			@@center_mass_limit = Setup.bank.class::CENTER_MASS_LIMIT
			@@center_mass_limit ||= CENTER_MASS_LIMIT
		end
	end

	module Table
		TABLE_OFFSET = 6

		def self.offset
			@@offset = Setup.bank.class::TABLE_OFFSET
			@@offset ||= TABLE_OFFSET
		end
	end

	module Printing
		TAB_SIZE = 30
	end

	module Type
		PERCENTAGE = 	1
		AMOUNT = 		2
		INTEGER = 		3
		FLOAT = 		4
		CURRENCY = 		5
		ASSET = 		6
		LABEL = 		7
	end

	def self.set_enviroment(format)
		puts "Setting Up"
		case format
		when Format::TEST
			puts "TEST BANK selected"
			@@bank = Test.new()
		when Format::HSBC
			puts "HSBC selected"
			@@bank = HSBC.new()
		end

	end

	def self.bank
		@@bank
	end

end

class Bank

	# FINE TUNNING parameters:
	# Override in sub-classes for bank specific
	# or modify in module for global effect
	TABLE_OFFSET = nil
	HORIZONTAL_SEARCH_RANGE = nil
	VERTICAL_SEARCH_RANGE = nil
	WILDCHAR = nil
	DATE_FORMAT = nil
	CENTER_MASS_LIMIT = nil

	attr_reader :files

	def initialize()
		raise NoMethodError, "Bank is an abstract class"
	end

	def prepare()
		raise NoMethodError, "Bank is an abstract class"
	end

	def execute()
		raise NoMethodError, "Bank is an abstract class"
	end

	def results()
		raise NoMethodError, "Bank is an abstract class"
	end

	def get_regex(type, bounded = true)
		return Regexp.new('^'<<regex(type)<<'$') if bounded
		return Regexp.new(regex(type))
	end

	def run 
		prepare
		load
		execute
		results
	end

	def prepare
		puts "preparing..."
		declare_fields
		setup_files
	end

	def load
		@charts = []
		@files.each.with_index do |file, i|
			chart = Chart.new(file)
			chart.fields = @fields[i]
			@charts << chart
		end
	end

	def execute
		puts "executing..."
		@charts.each do |chart|
			@reader = Reader.new(chart.file)
			unless chart.fields.nil?
				chart.fields.each do |field|
					puts "EXECUTING: #{field}"
					field.execute(@reader) 
				end
			end
		end
	end

	def results
		puts "results..."
		@charts.each do |chart|
			puts "CHART #{chart.file}:"
			unless chart.fields.nil?
				chart.fields.each do |field|
					field.print_results unless field.is_a? Action
				end
			end
		end
	end

end