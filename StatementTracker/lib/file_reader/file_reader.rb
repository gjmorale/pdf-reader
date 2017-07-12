module FileReader

	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
	require File.dirname(__FILE__) + '/config/Setup.rb'
	require File.dirname(__FILE__) + '/config/Institution.rb'
	require File.dirname(__FILE__) + '/config/Banks/BankUtils.rb'
	require File.dirname(__FILE__) + '/config/Banks/AssetTable.rb'
	require File.dirname(__FILE__) + '/config/Banks/TransactionTable.rb'
	Dir[File.dirname(__FILE__)     + '/config/Banks/AssetTables/*.rb'].each {|file| require_relative file } 
	require File.dirname(__FILE__) + '/config/Banks/HSBC.rb'
	require File.dirname(__FILE__) + '/config/Banks/HSBC_Account.rb'
	require File.dirname(__FILE__) + '/config/Banks/MorganStanley.rb'
	require File.dirname(__FILE__) + '/config/Banks/MS_Account.rb'
	require File.dirname(__FILE__) + '/config/Banks/Security.rb'
	require File.dirname(__FILE__) + '/config/Banks/SEC_Account.rb'
	require File.dirname(__FILE__) + '/config/Banks/Banchile.rb'
	require File.dirname(__FILE__) + '/config/Banks/Moneda.rb'
	require File.dirname(__FILE__) + '/config/Banks/CrediCorp.rb'
	require File.dirname(__FILE__) + '/config/Banks/Pershing.rb'
	require File.dirname(__FILE__) + '/config/Errors.rb'
end