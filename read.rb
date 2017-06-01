#!/usr/bin/env ruby
# encoding: utf-8
require_relative "dev/pdf_reader.rb"
require_relative "pdf_ghost/ghost.rb"
require_relative "pdf_meta/meta.rb"

 #in_path = "#{File.dirname(__FILE__)}/in" 			#DEBUG
 #out_path = "#{File.dirname(__FILE__)}/out" 		#DEBUG
 #mid_path = "#{File.dirname(__FILE__)}/dev/in" 	#DEBUG

 # Instituciones Financieras

 # MS	-> Morgan Stanley
 # HSBC -> HSBC

 #in_path = 'C:/Users/windows7/Desktop/Cartolas'		#PC_1
 #in_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas'#PC_2
 #in_path = Dir.home + '/gmo/Cartolas'					#VAIO
 in_path = Dir.home + '/gmo/Sandbox/Prueba'		#VAIO_CONFLICTO
 out_path = in_path 									#RELEASE
 mid_path = in_path + '/temp'

 skip = false

if ARGV.size > 0
	skip = true if ARGV[0] == "--skip-raw"
	skip = true if ARGV[0] == "-s"
end

puts " === DETECTING FILES === "
files = FileMeta.classify_files in_path

puts " === LOADING FILES === "
FileFilter.filter_files files, mid_path unless skip

banks = files.uniq{|b| b[0]}

puts " === PROCESSING FILES === "
FileReader.read_files banks, mid_path, out_path