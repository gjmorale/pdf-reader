#!/usr/bin/env ruby
module FileFilter
	require 'rubygems'
	require 'pdf/reader'
	require 'fileutils'
	Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }


	def self.filter_files format
		cleaner = Cleaner.new
		cleaner.load "in", "dev/in", format
		cleaner.execute
	end
end