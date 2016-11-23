class Test < Bank

	def initialize
		#Empty initialize required in very bank sub-class
		#Only to check it's not abstract
	end

	def get_regex(type)
		case type
		when Setup::Type::PERCENTAGE
			/^[+-]?(100\.0000|[1-9]?\d\.\d{1}%)$/
		when Setup::Type::AMOUNT
			/^[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{1}$/
		when Setup::Type::LABEL
			/^.*$/
		end
	end

	def setup_files
		@files = Dir["test_cases/*est.txt"]
		@charts = []
		@files.each.with_index do |file, i|
			chart = Chart.new(file)
			chart.fields = @fields[i]
			@charts << chart
		end
	end

	def declare_fields
		@fields = []
		#For file 1
		@fields[0] = []
		@fields[0] << Field.new(["doble","linea"], 2)
		@fields[0] << Field.new("UNO", 1)
		@fields[0] << SingleField.new("Campo", 1, nil, 5, [Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		headers = []
		headers << HeaderField.new("UNO", 1, headers.length, Setup::Type::AMOUNT)
		headers << HeaderField.new("DOS", 1, headers.length, Setup::Type::PERCENTAGE)
		headers << HeaderField.new("TRES", 1, headers.length, Setup::Type::PERCENTAGE)
		@fields[0] << Table.new("file", 1, headers, 2)
		@fields
	end

	def prepare
		puts "preparing..."
		declare_fields
		setup_files
	end

	def execute
		puts "executing..."
		@charts.each do |chart|
			@reader = Reader.new(nil)
			@reader.mock_content(File.read('test_cases/test.txt'))
			chart.fields.each do |field|
				field.execute(@reader)
			end
		end
	end

	def results
		puts "results..."
		@charts.each do |chart|
			puts "CHART #{chart.file}:"
			chart.fields.each do |field|
				field.print_results
			end
		end
	end

	private

end