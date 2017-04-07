#!/usr/bin/env ruby
# encoding: utf-8
require_relative "dev/pdf_reader.rb"
require_relative "pdf_ghost/ghost.rb"

 #in_path = "#{File.dirname(__FILE__)}/in" 			#DEBUG
 #out_path = "#{File.dirname(__FILE__)}/out" 		#DEBUG
 #mid_path = "#{File.dirname(__FILE__)}/dev/in" 	#DEBUG
 mid_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas/temp'

 # Instituciones Financieras

 # MS	-> Morgan Stanley
 # HSBC -> HSBC

 #in_path = 'C:/Users/windows7/Desktop/Cartolas'		#PC_1
 in_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas'#PC_2
 out_path = in_path 									#RELEASE


puts " === LOADING FILES FOR #{ARGV[0]} === "
FileFilter.filter_files ARGV[0], in_path, mid_path

puts " === PROCESSING FILES === "
FileReader.read_files ARGV[0], mid_path, out_path