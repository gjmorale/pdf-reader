class Test < Bank

	module Custom
		# Include custom formats specific for the bank here
		# Use negative indexes to avoid conflicts with Bank::Type
		# E.g: ACCOUNT_CODE = -1
		# And be sure to add a regex in the regex(type) method below
	end

	def initialize
		#Empty initialize required in every bank sub-class
		#Only to check it's not abstract
	end

	# Regex definition for each type of data including Custom
	# formats. IMPORTANT: Must be in sigle cuotes
	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d)\.\d{1}%'
		when Setup::Type::AMOUNT
			'[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{1}'
		when Setup::Type::LABEL
			'.*'
		end
	end

	# Only required public method. It executes anything
	# required to obtain the results of the bank
	def run
		@reader = Reader.new(nil)
		@reader.mock_content(File.read('test_cases/test.txt'))
		declare_fields.each do |field|
			puts "EXECUTING: #{field}"
			field.execute(@reader)
			field.print_results unless field.is_a? Action
		end
	end

	private
		# Fields can take 5 forms:
		# Field: lib/Field.rb
		# SingleField: lib/Field.rb
		# HeaderField: lib/Field.rb
		# Table: lib/Table.rb
		# Action: lib/Action.rb
		# See each class file for more information
		def declare_fields
			@fields = []
			@fields << SingleField.new(["doble","linea"], [Setup::Type::PERCENTAGE, Setup::Type::AMOUNT], 2)
			@fields << Field.new("UNO")
			@fields << SingleField.new("Campo", [Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
			headers = []
			headers << HeaderField.new("UNO", headers.length, Setup::Type::AMOUNT, false, 1)
			headers << HeaderField.new(["DOS","a"], headers.length, Setup::Type::PERCENTAGE, true,  2)
			headers << HeaderField.new("TRES", headers.length, Setup::Type::PERCENTAGE, false, 1)
			bottom = Field.new("0123456")
			@fields << Table.new(headers, bottom)
			@fields
		end

end