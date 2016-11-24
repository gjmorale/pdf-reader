class HSBC < Bank

	def initialize
		#Empty initialize required in very bank sub-class
		#Only to check it's not abstract
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'[+-]?(100|[1-9]?\d)\.\d{2}%'
		when Setup::Type::AMOUNT
			'[+-]?[0-9]{1,3}(?:,?[0-9]{3})*\.[0-9]{2}'
		when Setup::Type::INTEGER
			'[+-]?[1-9]\d{0,2}(?:,+?[0-9]{3})*'
		when Setup::Type::CURRENCY
			'(EUR|USD|CAD|JPY){1}'
		when Setup::Type::ASSET
			'(Equities|Fixed Income|Liquidity and Money Market|Others){1}'
		when Setup::Type::LABEL
			'.*'
		end
	end

	def setup_files
		@files = Dir["test_cases/*.pdf"]
	end

	def declare_fields
		@fields = []
		@fields[0] = [] #First document
		@fields[0] << SingleField.new("Portfolios consolidated for this account: ",[Setup::Type::INTEGER])
		headers = []
		headers << HeaderField.new("Portfolio", headers.size, Setup::Type::LABEL)
		headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
		headers << HeaderField.new("Market value in USD", headers.size, Setup::Type::AMOUNT, true)
		bottom = Field.new("TOTAL PORTFOLIOS IN CREDIT")
		@fields[0] << Table.new(headers, bottom)
	end
=begin
	def declare_fields
		@fields = []
		@fields << SingleField.new("OTHER HOLDINGS", 1, @files[0], 5, [Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		@fields << SingleField.new('ODEBRECHT FINANCE LTD 7,5% 10-W/O FIXED MATURITY', 1, @files[0], 5, [Setup::Type::CURRENCY, Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		@fields << SingleField.new('AMUNDI FDS ABSOLUTE', 1, @files[0], 5, [Setup::Type::ASSET, Setup::Type::CURRENCY, Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		@fields << SingleField.new('Fixed Income', 1, @files[0], 4, [Setup::Type::AMOUNT, Setup::Type::AMOUNT, Setup::Type::PERCENTAGE])
		@fields << SingleField.new('Total assets at',1, @files[0], 7, [Setup::Type::AMOUNT], true)
		@fields
	end

	def declare_tables
		@tables = []
		headers = []
		headers << HeaderField.new("Description", 2, 1, Setup::Type::LABEL)
		headers << HeaderField.new("Cur.", 2, 2, Setup::Type::CURRENCY)
		headers << HeaderField.new("Valuation (USD)", 2, 3, Setup::Type::AMOUNT)
		headers << HeaderField.new("P&L", 1, 4, Setup::Type::PERCENTAGE)
		bottom = Field.new("5 worst performers since inception", 1)
		@tables << Table.new(@files[0], 12, headers, 5, bottom)
		headers = []
		headers << HeaderField.new("Description", 2, 1, Setup::Type::LABEL)
		headers << HeaderField.new("Cur.", 2, 2, Setup::Type::CURRENCY)
		headers << HeaderField.new("Valuation (USD)", 2, 3, Setup::Type::AMOUNT)
		headers << HeaderField.new("P&L", 1, 4, Setup::Type::PERCENTAGE)
		table = Table.new(@files[0], 12, headers.dup, 5)
		offset = Field.new("5 worst performers since inception", 1)
		table.set_offset offset
		@tables << table
		@tables
	end

	private
=end
end