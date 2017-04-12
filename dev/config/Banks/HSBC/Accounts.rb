class HSBC::AccountsTable < HSBCAssetTable

	def get_results
		new_accounts = []
		present = get_table do |table|
			table.rows.each.with_index do |row, i|
				results = table.headers.map {|h| h.results[-i-1].result}
				account_data = parse_account(results[0])
				account = AccountHSBC.new(account_data[0], account_data[1])
				account.value = BankUtils.to_number(results[2])
				new_accounts << account
			end
		end
		if present
			return new_accounts
		else 
			puts "#{name} table is missing #{@reader}" if verbose
		end
	end
end

class HSBC::Accounts < HSBC::AccountsTable
	def load
		@name = "accounts"
		@title = Field.new("Portfolios consolidated for this account:")
		@table_end = Field.new("TOTAL PORTFOLIOS IN CREDIT")
		@headers = []
			headers << HeaderField.new("Portfolio", headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cur.", headers.size, Setup::Type::CURRENCY, true)
			headers << HeaderField.new("Market value in USD", headers.size, Setup::Type::AMOUNT, true)
		@total = SingleField.new("NET ASSETS",[Setup::Type::AMOUNT])
		@total_index = 0
	end
end