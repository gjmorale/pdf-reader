class PER::AssetTable < AssetTable
	Dir[File.dirname(__FILE__) + '/AssetTables/*.rb'].each {|file| require_relative file } 

	def pre_load *args
		super
		@label_index = 10
	end

	def each_result_do results, row=nil
		text = row.upper_text
		text = (text.is_a?(Multiline) ? text.strings : [text]) 
		text = text.map{|s| s.gsub(/¶{3}¶+/,';').gsub(/¶/,'').gsub(';;',';')}
		options = text.join(';').split(';')
		if options.select{|o| o =~ /\(continuación\)/}.any?
			results[label_index] = Result::NOT_FOUND 
		else
			text = options.select{|o| 
				not o.empty? and
				o =~ /.*[A-Z]{3}.*/ and
				not (o =~ /(Total|Código|Opción|Efectivo|^\s*$)/)
			}.each{|o| o.strip!}.join(';').gsub(/;(?!CUSIP)/,' ')
			results[label_index] = text.empty? ? Result::NOT_FOUND : text
		end
	end
end
