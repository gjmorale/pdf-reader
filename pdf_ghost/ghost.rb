#!/usr/bin/env ruby
module FileFilter
	require 'rubygems'
	require 'pdf/reader'
	require 'fileutils'
	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


	def self.filter_files format
		cleaner = Cleaner.new
		#cleaner.load "#{Dir.home}/pdf_reader/in", "#{Dir.home}/pdf_reader/raw", format
		cleaner.load "#{File.dirname(__FILE__)}/../../pdf-reader/in", "#{File.dirname(__FILE__)}/../../pdf-reader/dev/in", format
		cleaner.execute
	end
end