#!/usr/bin/env ruby
module FileReader

	require 'rubygems'

	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
	require File.dirname(__FILE__) + '/config/Setup.rb'
	require File.dirname(__FILE__) + '/config/Banks/Bank.rb'
	require File.dirname(__FILE__) + '/config/Banks/AssetTable.rb'
	Dir[File.dirname(__FILE__)     + '/config/Banks/AssetTables/*.rb'].each {|file| require_relative file } 
	require File.dirname(__FILE__) + '/config/Banks/HSBC.rb'
	require File.dirname(__FILE__) + '/config/Banks/HSBC_Account.rb'
	require File.dirname(__FILE__) + '/config/Banks/MorganStanley.rb'
	require File.dirname(__FILE__) + '/config/Banks/MS_Account.rb'
	require File.dirname(__FILE__) + '/config/Banks/Security.rb'
	require File.dirname(__FILE__) + '/config/Banks/SEC_Account.rb'
	require File.dirname(__FILE__) + '/config/Errors.rb'

	#Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file }
	#Dir[File.dirname(__FILE__) + '/config/**/*.rb'].each {|file| require file }
	#Dir[File.dirname(__FILE__) + '/config/MedCares/*.rb'].sort.each {|file| require file }


	def self.read_files format, in_path, out_path
		format = format
		Setup.set_enviroment(format, in_path, out_path)
		puts '------------------------------------'
		Setup.inst.run
	end
end