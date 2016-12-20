#!/usr/bin/env ruby
require 'rubygems'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
require File.dirname(__FILE__) + '/config/Setup.rb'
Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/config/**/*.rb'].each {|file| require file }
#Dir[File.dirname(__FILE__) + '/config/MedCares/*.rb'].sort.each {|file| require file }

 
format = ARGV[0]
Setup.set_enviroment(format)

Setup.inst.run