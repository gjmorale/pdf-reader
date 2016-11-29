require 'rubygems'
require 'pdf/reader'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
require File.dirname(__FILE__) + '/config/Setup.rb'
Dir[File.dirname(__FILE__) + '/config/*.rb'].each {|file| require file }

 
format = ARGV[0]
Setup.set_enviroment(format)
=begin
Setup.bank.setup_files

#MAIN#
Setup.bank.files.each do |file|
	reader = Reader.new(file)
	reader.print_file(file)
end

@fields = Setup.bank.declare_fields
=end

Setup.bank.run

#reader = Reader.new(Dir["test_cases/*.pdf"][0])
#reader.mock_content(File.read('test_cases/test.txt'))
#@fields = Setup.bank.declare_fields
#reader.read_continue(@fields)
#@tables = Setup.bank.declare_tables
#reader.read_tables(@tables)

=begin
runs = [1,2,3,4]

a = runs.group_by { |char|
        char%2
      }

      puts a

      a.map { |y, chars|
        chars
        #group_chars_into_runs(chars.sort)
      }.flatten.sort

      puts a

      a = runs.group_by { |char|
        char%2
      }.map { |y, chars|
        chars
        #group_chars_into_runs(chars.sort)
      }.flatten.sort

      puts a

=end