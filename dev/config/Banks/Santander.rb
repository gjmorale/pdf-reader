require_relative "Bank.rb"
require 'date'

class SAN < Bank
	DIR = "SAN"
	LEGACY = "Santander"
	VERTICAL_SEARCH_RANGE = 40
	TABLE_OFFSET = 20
	HEADER_OFFSET = 10
end

Dir[File.dirname(__FILE__) + '/SAN/*.rb'].each {|file| require_relative file } 

SAN.class_eval do

	def dir
		self.class::DIR
	end

	def legacy_code
		self.class::LEGACY
	end

	module Custom
		ACC_NAME = -1
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'-?(100|[1-9]?\d\.\d{2})\s?%'
		when Setup::Type::AMOUNT
			'-?([1-9]\d{0,2}(?:\,\d{3})*|0)\.\d\d'
		when Setup::Type::INTEGER
			'-?\$?([1-9]\d{0,2}(?:\,\d{3})*|0)'
		when Setup::Type::CURRENCY
			'(CLP|EUR|USD|CAD|JPY|GBP|DO){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*[a-zA-Z].*'
		when Setup::Type::DATE
			'(?<! )\d\d-[A-Z]{3}-\d\d'
		when Setup::Type::FLOAT
			'-?([1-9]\d{0,2}(?:\.[0-9]{3})*|0)(\,[0-9]{4})'
		when Setup::Type::BLANK
			'Impossible Match'
		when Custom::ACC_NAME
			'\d{1,2} ?(CLP|EUR|USD|CAD|JPY|GBP|DO) - [A-Z ]+'
		end
	end

	MONTHS = [
		[ 1, "ENE"],
		[ 2, "FEB"],
		[ 3, "MAR"],
		[ 4, "ABR"],
		[ 5, "MAY"],
		[ 6, "JUN"],
		[ 7, "JUL"],
		[ 8, "AGO"],
		[ 9, "SEP"],
		[10, "OCT"],
		[11, "NOV"],
		[12, "DIC"],
	]

	def self.value_to_date value
		return nil unless value and value.is_a? String and not value.empty? 
		args = value.strip.split('-')
		return nil unless args.size == 3
		day = args[0].to_i
		month = MONTHS.select{|m| m[1] == args[1]}.first[0]
		year = 2000+args[2].to_i
		Date.new(year, month, day)
	end

	private

		def analyse_position file
			@reader = Reader.new(file)
			@accounts = []

			Field.new("Resumen").execute @reader
			while Field.new("Resumen").execute @reader
				acc_field = SingleField.new("Portfolio", [Custom::ACC_NAME])
				acc_field.execute @reader
				acc_field.print_results
				account = SAN::Account.new(acc_field.results[0], 777.0)

				#Field.new("Extracto de cuenta").execute @reader

				movs = SAN::TransactionsUSD.new(@reader).analyze
				account.add_mov movs
				@reader.next_page if movs and movs.any? 
				movs = SAN::TransactionsEUR.new(@reader).analyze
				account.add_mov movs
				@reader.next_page if movs and movs.any? 
				movs = SAN::TransactionsJPY.new(@reader).analyze
				account.add_mov movs
				@accounts << account
			end

		end

		def pre_print
			@accounts.each do |account|
				account.movements.select{|m| m.concepto == 9990}.each do |buyer|
					seller = account.movements.find do |m| 
						m.concepto == 9991 and m.forward_id == buyer.forward_id
					end
					seller.merge buyer
					seller.concepto = 9004
					seller.detalle = buyer.forward_id
					account.movements.delete buyer
				end
			end
		end
end