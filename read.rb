#!/usr/bin/env ruby
# encoding: utf-8
require_relative "dev/pdf_reader.rb"
require_relative "pdf_ghost/ghost.rb"
require_relative "pdf_meta/meta.rb"
require 'optparse'
require 'ostruct'

 #in_path = "#{File.dirname(__FILE__)}/in" 			#DEBUG
 #out_path = "#{File.dirname(__FILE__)}/out" 		#DEBUG
 #mid_path = "#{File.dirname(__FILE__)}/dev/in" 	#DEBUG

options = OpenStruct.new
options.skip_raw = false
options.filter = nil
options.source_in = nil
options.source_out = nil
options.source_mid = nil
options.banks = nil

OptionParser.new do |opt|

	opt.banner = "Usage: example.rb [options]"
    opt.separator ""
    opt.separator "Specific options:"

	opt.on('-s','--skip-raw [SKIP]','Skip the reading of the original PDF') do |o| 
		options.skip_raw = o || true
	end
	opt.on('-f','--filter FILTER','Only process files containing FILTER') { |o| options.filter = o }
	opt.on('-i','--in_path DIR','Process PDF files from DIR') { |o| options.source_in = o }
	opt.on('-o','--out_path DIR','Save output to DIR') { |o| options.source_out = o }
	opt.on('-t','--temp_path DIR','Store temp files in DIR') { |o| options.source_mid = o }
	opt.on('-b','--banks x,y,z',Array,'Only process files from the banks listed') do |list| 
		list = list.map{|l| Setup.set_manual_enviroment l }
		options.banks = list.select {|l| l}
	end
end.parse!

puts options



 # Instituciones Financieras

 # MS	-> Morgan Stanley
 # HSBC -> HSBC

 #in_path = 'C:/Users/windows7/Desktop/Cartolas'		#PC_1
 #in_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas'#PC_2
 #in_path = Dir.home + '/gmo/Cartolas'					#VAIO
 in_path = Dir.home + '/gmo/Sandbox/Prueba'		#VAIO_CONFLICTO
 out_path = in_path 									#RELEASE
 mid_path = in_path + '/temp'
 in_path = options.source_in || in_path
 out_path = options.source_out || out_path
 mid_path = options.source_mid || mid_path

 skip = false

if ARGV.size > 0
	skip = true if ARGV[0] == "--skip-raw"
	skip = true if ARGV[0] == "-s"
end

puts " === DETECTING FILES === "
files = FileMeta.classify_files in_path
files = files.select{|f| options.banks.include? f[0]} if options.banks
puts "#{files.size} files detected\n"
puts "#{files.map{|f| f[0]}}"
raise

puts " === LOADING FILES === "
FileFilter.filter_files files, mid_path unless skip

banks = files.uniq{|b| b[0]}.map{|b| b[0]}

puts " === PROCESSING FILES === "
FileReader.read_files banks, mid_path, out_path