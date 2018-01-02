class PER::AssetTable < AssetTable
	Dir[File.dirname(__FILE__) + '/*/AssetTable.rb'].each {|file| require_relative file } 
	Dir[File.dirname(__FILE__) + '/*/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		@label_index = 10
	end

	def each_result_do results, row=nil
		@last_title_stored = row.lower_text unless row.lower_text.nil? or row.lower_text =~ /^¶*$/
		text = clean_text row.upper_text
		if @last_title_stored and text == Result::NOT_FOUND
			text = clean_text @last_title_stored
			@last_title_stored = nil
		end
		results[label_index] = text
	end

	def clean_text text
		text = (text.is_a?(Multiline) ? text.strings : [text]) 
		text = text.map{|s| s.gsub(/¶{3}¶+/,';').gsub(/¶/,'').gsub(';;',';')}
		options = text.join(';').split(';')
		if options.select{|o| o =~ /\((continuación|continuation)\)/}.any? or options.empty?
			return Result::NOT_FOUND 
		else
			text = filter_text options
			return text.empty? ? Result::NOT_FOUND : text
		end
	end

	def filter_text options
		text = options.select{|o| 
			not o.empty? and
			o =~ /.*[A-Z]{2}.*/ and
			not (o =~ /(Total|Código|Opción|Efectivo|Fondo de Inv|Precio estimado|DTD|MATURITY|^\s*$)/)
		}.each{|o| o.strip!}.join(';')
		text = text.gsub(/;(?!CUSIP)/,' ')
		text = text.gsub(/\s?ISIN/, ';ISIN')
		text = text.gsub(/ISIN;/,'ISIN ')
		text = text.gsub(/(?<=ISIN#.{12})\s.+$/,'').gsub(/ISIN#/,'ISIN ')
		text
	end
end
