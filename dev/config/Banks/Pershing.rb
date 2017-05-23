require_relative "Bank.rb"
require 'date'

class PER < Bank
	DIR = "PER"
	LEGACY = "Pershing"
	TABLE_OFFSET = 30
end

Dir[File.dirname(__FILE__) + '/PER/*.rb'].each {|file| require_relative file } 

PER.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		NUM2 = 		-1
		NUM3 = 		-2
		NUM4 = 		-3
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'-?(100|[1-9]?\d\.\d{2})\s?%'
		when Setup::Type::AMOUNT
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})?|0)(?:\.\d+)?'
		when Setup::Type::INTEGER
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})?|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.+'
		when Setup::Type::DATE
			'(\d{2}\/\d{2}\/\d{2}|Total(\s?Cubierto)?\s*$)'
		when Setup::Type::FLOAT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{4})'
		when Setup::Type::BLANK
			'Impossible Match'
		when Custom::NUM2
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})?|0)\.\d{2}'
		when Custom::NUM3
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})?|0)\.\d{3}'
		when Custom::NUM4
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})?|0)\.\d{4}'
		end
	end

	private  

		def set_date value1, value2
			day, month, year = value2.split('-')
			if value2.eql? value1
				date = Date.strptime(value1, "%d-%m-%Y")
				day = date.next_month.prev_day.day
			end
			@date_out = "#{day}-#{month}-#{year}"
			puts @date_out
		end

		def analyse_position file
			@reader = Reader.new(file)
			@accounts = []

			Field.new("PRODUCTOS NEGOCIADOS EN BOLSA").execute @reader
			@reader.go_to(@reader.page)
			analyse_etfs
		end

		def analyse_etfs
			return PER::ETFS.new(@reader, true).analyze
		end
end