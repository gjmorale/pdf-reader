#!/usr/bin/env ruby
require 'rubygems'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
require File.dirname(__FILE__) + '/config/Setup.rb'
require File.dirname(__FILE__) + '/config/Banks/Bank.rb'
require File.dirname(__FILE__) + '/config/Banks/HSBC.rb'
require File.dirname(__FILE__) + '/config/Banks/HSBC_Account.rb'
require File.dirname(__FILE__) + '/config/Banks/MorganStanley.rb'
require File.dirname(__FILE__) + '/config/Banks/MS_Account.rb'
require File.dirname(__FILE__) + '/config/Errors.rb'

#Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file }
#Dir[File.dirname(__FILE__) + '/config/**/*.rb'].each {|file| require file }
#Dir[File.dirname(__FILE__) + '/config/MedCares/*.rb'].sort.each {|file| require file }

 
format = ARGV[0]
Setup.set_enviroment(format)

Setup.inst.run