#!/usr/bin/env ruby
require_relative "dev/pdf_reader.rb"
require_relative "pdf_ghost/ghost.rb"

puts " === LOADING FILES FOR #{ARGV[0]} === "
FileFilter.filter_files ARGV[0]

puts " === PROCESSING FILES === "
FileReader.read_files ARGV[0]