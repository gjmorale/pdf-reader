class AccountsTable < AssetTable

	def get_results
		new_accounts = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				new_accounts << AccountMS.new(BankUtils.parse_account(results[0]), 
					BankUtils.to_number(results[5]))
			end
		end
		if present
			return new_accounts
		else 
			puts "#{name} table is missing #{@reader}" if verbose
		end
	end
end

class BussinessAccounts < AccountsTable
	def load
		@name = "bussiness accounts"
		@title = Field.new("OVERVIEW OF YOUR ACCOUNT")
		@table_end = Field.new("Total Business Accounts")
		@headers = []
			headers << HeaderField.new("Account Number", headers.size, Custom::ACC_CODE, false)
			headers << HeaderField.new("Beginning Value", headers.size, Setup::Type::INTEGER, true)
			headers << HeaderField.new(["Funds","Credited/(Debited)"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Security/Currency","Transfers","Rcvd/(Dlvd)"], headers.size, Setup::Type::INTEGER, false, 6)
			headers << HeaderField.new("Change in Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new("Ending Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Income/Dist","This Period/YTD"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 4)
			headers << HeaderField.new(["YTD Realized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new("Page", headers.size, Custom::PAGE, true, 4)
		@offset = [Field.new("Business Accounts")]
		@total = SingleField.new("Total Business Accounts",
			[Setup::Type::INTEGER,
			Setup::Type::INTEGER,
			Setup::Type::INTEGER,
			Setup::Type::INTEGER,
			Setup::Type::INTEGER,
			Setup::Type::INTEGER], 
			5, Setup::Align::LEFT)
		@total_index = 4
	end
end

class PersonalAccounts < AccountsTable
	def load
		@name = "personal accounts"
		@title = Field.new("OVERVIEW OF YOUR ACCOUNT")
		@table_end = Field.new("Total Personal Accounts")
		@headers = []
			headers << HeaderField.new("Account Number", headers.size, Custom::ACC_CODE, false)
			headers << HeaderField.new("Beginning Value", headers.size, Setup::Type::INTEGER, true)
			headers << HeaderField.new(["Funds","Credited/(Debited)"], headers.size, BankUtils.to_arr(Setup::Type::LABEL, 2), false, 4)
			headers << HeaderField.new(["Security/Currency","Transfers","Rcvd/(Dlvd)"], headers.size, Setup::Type::INTEGER, false, 6)
			headers << HeaderField.new("Change in Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new("Ending Value", headers.size, Setup::Type::INTEGER, false, 4)
			headers << HeaderField.new(["Income/Dist","This Period/YTD"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 4)
			headers << HeaderField.new(["YTD Realized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new(["Unrealized","Gain/(Loss)","(Total ST/LT)"], headers.size, [Setup::Type::INTEGER, Setup::Type::INTEGER], false, 6)
			headers << HeaderField.new("Page", headers.size, Custom::PAGE, true, 4)
		@offset = [Field.new("Personal Accounts")]
		@total = SingleField.new("Total Personal Accounts",
			[Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::AMOUNT,
			Setup::Type::AMOUNT], 
			5, Setup::Align::LEFT)
		@total_index = 4
	end
end
