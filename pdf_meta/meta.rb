#!/usr/bin/env ruby
# coding: utf-8

module FileMeta

	require 'rubygems'
	require 'pdf/reader'

	module FileMeta::Map
		PRODUCERS = [
			[BC, /Acrobat PDFWriter 5\.0 para Windows NT/],
			[BC, /Apache FOP Version 1\.0/],
			[HSBC, /Actuate XML to PDF Converter 1\.0/],
			[MON, /ComponentOne PDF Generator 8\.0/],
			[MS, /Aspose\.Pdf\.Kit for \.NET 5\.0\.0\.1/],
			[PER, /303l Linux \(64bit\)/],
			[SEC, /Adobe LiveCycle Output 8\.2/]
		]
		CREATORS = [
			[CrediCorp, /wkhtmltopdf 0\.12\.3\.1/],
			[MS, /Morgan Stanley/],
			[PER, /Ricoh Production Print Solutions Afp2Pdf Version: 303l/]
		]
	end

	def self.read_field field_name, reader
		field = reader.info.inspect.match /(?<=:#{Regexp.quote field_name}=>)(#<[^>]+>|\"[^\"]+\")(?=,\s:|})/
		field = "#{field}"
		if(field_id = field.match /(?<=@id=)\d+(?=,)/)
			field_id = "#{field_id}".to_i
			field = reader.objects[field_id] if field_id > 0
		end
		return field
	end

	def self.clean_date str
		str = "#{str.match /(?<=D:)\d{8}/}"
		str = str[6..7] << '-' << str[4..5] << '-' << str[0..3]
	end

	def self.match str, collection
		collection.each do |term|
			return term[0] if str.match term[1]
		end
		return false
	end

	def self.classify_files in_path
		raise IOError, "No se encontró la carpeta #{in_path}" unless Dir.exist? "#{in_path}"

		files = Dir["#{in_path}/*.pdf"].sort
		files_out = []

		files.each do |filename|
			producer = creator = ""
			PDF::Reader.open(filename) do |reader|
				#puts "\n===> #{filename[filename.rindex('/')..-5]}"
				#puts "CREATED: #{clean_date read_field("CreationDate", reader)}"
				producer = read_field "Producer", reader
				creator = read_field "Creator", reader
				#puts reader.info.inspect
			end
			bank = 
				FileMeta.match(producer, FileMeta::Map::PRODUCERS) || 
				FileMeta.match(creator, FileMeta::Map::CREATORS)
			files_out << [bank, filename] if bank
		end
		files_out
	end
end