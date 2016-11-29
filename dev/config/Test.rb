class Test < Bank

	def initialize
		#Empty initialize required in very bank sub-class
		#Only to check it's not abstract
	end

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

	def setup_files
	end

	def run
		@reader = Reader.new(nil)
		@reader.mock_content(File.read('test_cases/test.txt'))
		chart.fields.each do |field|
			puts "EXECUTING: #{field}"
			field.execute(@reader)
		end
	end

	def declare_fields
		@fields = []
		#For file 1
		@fields[0] = []
		@fields[0] << SingleField.new(["doble","linea"], [Setup::Type::PERCENTAGE, Setup::Type::AMOUNT], 2)
		@fields[0] << Field.new("UNO")
		@fields[0] << SingleField.new("Campo", [Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		headers = []
		headers << HeaderField.new("UNO", headers.length, Setup::Type::AMOUNT, false, 1)
		headers << HeaderField.new(["DOS","a"], headers.length, Setup::Type::PERCENTAGE, true,  2)
		headers << HeaderField.new("TRES", headers.length, Setup::Type::PERCENTAGE, false, 1)
		bottom = Field.new("0123456")
		@fields[0] << Table.new(headers, bottom)
		@fields
	end

end