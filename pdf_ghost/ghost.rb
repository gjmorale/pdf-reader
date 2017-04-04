#!/usr/bin/env ruby
module FileFilter
	require 'rubygems'
	require 'pdf/reader'
	require 'fileutils'
	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


	def self.filter_files format, in_path, out_path
		cleaner = Cleaner.new
		#cleaner.load "#{Dir.home}/pdf_reader/in", "#{Dir.home}/pdf_reader/raw", format
		cleaner.load in_path, out_path, format
		cleaner.execute
	end
end