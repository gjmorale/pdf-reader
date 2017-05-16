#!/usr/bin/env ruby
# encoding: utf-8
require_relative "dev/pdf_reader.rb"
require_relative "pdf_ghost/ghost.rb"

 #in_path = "#{File.dirname(__FILE__)}/in" 			#DEBUG
 #out_path = "#{File.dirname(__FILE__)}/out" 		#DEBUG
 #mid_path = "#{File.dirname(__FILE__)}/dev/in" 	#DEBUG

 # Instituciones Financieras

 # MS	-> Morgan Stanley
 # HSBC -> HSBC

 #in_path = 'C:/Users/windows7/Desktop/Cartolas'		#PC_1
 #in_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas'#PC_2
 #in_path = Dir.home + '/gmo/Cartolas'					#VAIO
 in_path = Dir.home + '/gmo/Cartolas'		#VAIO_CONFLICTO
 out_path = in_path 									#RELEASE
 mid_path = in_path + '/temp'

 skip = false

if ARGV.size > 1
	skip = true if ARGV[1] == "--skip-raw"
end

puts " === LOADING FILES FOR #{ARGV[0]} === "
FileFilter.filter_files ARGV[0], in_path, mid_path unless skip

puts " === PROCESSING FILES === "
FileReader.read_files ARGV[0], mid_path, out_path