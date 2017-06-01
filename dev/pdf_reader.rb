#!/usr/bin/env ruby
module FileReader

	require 'rubygems'

	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
	require File.dirname(__FILE__) + '/config/Setup.rb'
	require File.dirname(__FILE__) + '/config/Banks/Bank.rb'
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

	#Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file }
	#Dir[File.dirname(__FILE__) + '/config/**/*.rb'].each {|file| require file }
	#Dir[File.dirname(__FILE__) + '/config/MedCares/*.rb'].sort.each {|file| require file }

	def self.set_files files
		files = files.map{|f| [f[0],f[1][f[1].rindex('/')+1..-5]]}
		puts files 
		files
	end

	def self.index_files formats, in_path, out_path
		files = []
		set_files(formats).each do |format|
			@bank ||= format[0]
			if @bank != format[0]
				Setup.set_enviroment(@bank, in_path, out_path)
				puts '------------------------------------'
				Setup.inst.index files
				files = []
				@bank = format[0] 
			end
			files << format[1]
		end
		if @bank
			Setup.set_enviroment(@bank, in_path, out_path)
			puts '------------------------------------'
			Setup.inst.index files
			@bank = format[0] 
		end
	end

	def self.read_files formats, in_path, out_path
		files = []
		set_files(formats).each do |format|
			@bank ||= format[0]
			if @bank != format[0]
				Setup.set_enviroment(@bank, in_path, out_path)
				puts '------------------------------------'
				Setup.inst.run files
				files = []
				@bank = format[0] 
			end
			files << format[1]
		end
		if @bank
			Setup.set_enviroment(@bank, in_path, out_path)
			puts '------------------------------------'
			Setup.inst.run files
		end
	end
end