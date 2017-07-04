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
options.recursive = nil
options.mode = :none
options.index = nil
options.process = true
options.source_in = nil
options.source_out = nil
options.source_mid = nil
options.date_from = nil
options.date_to = nil
options.banks = nil

OptionParser.new do |opt|

	opt.banner = "PDF-READER: FINANTEC 2017"
    opt.separator ""
    opt.separator "**WARNING** :	The temp file path is automatically destroyed in every run
		unless the flag --skip-raw [-s] is set. Be carefull with the
		rout you specify"
    opt.separator "Check the file read.rb to set your default route."
    opt.separator ""
    opt.separator "CODE -> Bank:"
    opt.separator "\tMS\tMorgan Stanley"
    opt.separator "\tHSBC\tHSBC"
    opt.separator "\tSEC\tSecurity"
    opt.separator "\tMON\tMoneda"
    opt.separator "\tBC\tBanChile"
    opt.separator "\tPER\tPershing"
    opt.separator "\tCORP\tCredicorp"
    opt.separator "\tMS\tMorgan Stanley"
    opt.separator ""
    opt.separator "Options:"

	opt.on('-s','--skip-raw','Skip the reading of the original PDF') { options.skip_raw = true }
	opt.on('-r','--recursive','Search in path recursively') { options.recursive = true }
	opt.on('-c','--index [MODE]',[:copy,:move,:none],'Find owner and date to index the file [MODE = none, copy, move]') do |o|
		options.index = true 
		options.mode = o if o
	end
	opt.on('-p','--[no-]process','Process files for results') {|o| options.process = o }
	opt.on('-f','--filter FILTER','Only process files containing FILTER') { |o| options.filter = /#{Regexp.quote o}/ }
	opt.on('-i','--in_path DIR','Process PDF files from DIR') { |o| options.source_in = o }
	opt.on('-o','--out_path DIR','Save output to DIR') { |o| options.source_out = o }
	opt.on('-t','--temp_path DIR','Store temp files in DIR') { |o| options.source_mid = o }
	opt.on('-a','--date_from DD,MM,YYYY', Array, 'Process files from this date') do |list|
		puts "#{list}"
		options.date_from = Date.strptime(list.join('-'),"%d-%m-%Y")
	end
	opt.on('-z','--date_to DD,MM,YYYY', Array, 'Process files until this date') do |list|
		options.date_to = Date.strptime(list.join('-'),"%d-%m-%Y")
	end
	opt.on('-b','--banks x,y,z',Array,'Only process files from the banks listed') do |list| 
		list = list.map{|l| Setup.set_manual_enviroment l }
		options.banks = list.select {|l| l}
	end
	opt.separator ""
end.parse!

 #in_path = 'C:/Users/windows7/Desktop/Cartolas'		#PC_1
 in_path = 'C:/Users/Guillermo Morales/Desktop/Cartolas'#PC_2
 #in_path = Dir.home + '/gmo/Cartolas'					#VAIO
 #in_path = Dir.home + '/gmo/Sandbox/Prueba'		#VAIO_CONFLICTO
 out_path = in_path + '/output'							#RELEASE
 mid_path = in_path + '/temp'
 in_path = options.source_in || in_path
 out_path = options.source_out || out_path
 mid_path = options.source_mid || mid_path


unless Dir.exist? "#{out_path}" or not options.process
	puts "No se encontró la carpeta de salida"
	puts "#{out_path}"
	puts "¿Quiere crear la carpeta? (Y/N)"
	if (STDIN.gets.chomp) =~ /^(Y|y|yes|Yes|YES|s|S|si|sí|Si|Sí|SI|SÍ)$/
		Dir.mkdir("#{out_path}") 
	else
		return "Not a DIR #{out_path}"
	end
end 

puts "\n === DETECTING FILES === ".bold
files = FileMeta.classify_files in_path, options.recursive, options.date_from, options.date_to
files = files.select{|f| options.banks.include? f[0]} if options.banks
files = files.select{|f| options.date_from <= f[2]} if options.date_from
files = files.select{|f| options.date_to >= f[2]} if options.date_to
files = files.select{|f| f[1] =~ options.filter} if options.filter
files.sort{|a,b| a[0]::DIR <=> b[0]::DIR}

message = "Total of #{files.size} files detected\n"
files.size == 0 ? puts(message.red) : puts(message.green)

unless options.skip_raw
	puts "\n === LOADING FILES === ".bold
	FileFilter.filter_files files, mid_path 
end

if options.index
	puts "\n === INDEXING FILES === ".bold
	FileReader.index_files files, mid_path, out_path
	if [:cut,:copy].include? options.mode
		puts "#{options.mode}"
	end
end

if options.process
	puts "\n === PROCESSING FILES === ".bold
	FileReader.read_files files, mid_path, out_path
end