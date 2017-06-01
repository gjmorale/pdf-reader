#!/usr/bin/env ruby
module FileFilter
	require 'rubygems'
	require 'pdf/reader'
	require 'fileutils'
	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


	def self.filter_files files, out_path
		cleaner = Cleaner.new
		#cleaner.load "#{Dir.home}/pdf_reader/in", "#{Dir.home}/pdf_reader/raw", format
		unless warning = cleaner.load(files, out_path)
			cleaner.execute
		else
			puts warning.red
		end
	end
end