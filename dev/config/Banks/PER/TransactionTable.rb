class PER::TransactionTable < TransactionTable

	def pre_load *args
		super
		@label_index = 		5
		@title_limit = 		4
	end

	def parse_movement hash
		hash[:fecha_pago] = hash[:fecha_movimiento] if (hash[:fecha_pago] =~ /Result not found/)
		hash[:value] = hash[:cantidad2]
		case hash[:concepto]
		when /^FEDERAL FUNDS/i
			hash[:id_ti1] = "Currency"
			hash[:cantidad1] = hash[:cantidad2]
			hash[:cantidad2] = 0
			hash[:id_ti_valor1] = hash[:id_ti_valor2]
			hash[:id_ti_valor2] = ""
			hash[:concepto] = 9001 
		when /(SOLD|Retiro)/i
			hash[:concepto] = 9005
		when /(PURCHASED|Dep.sito)/i
			hash[:concepto] = 9004
		when /(DIVIDEND|MONEY FUND INCOME)/i
			hash[:concepto] = 9006
		when /ALIEN TAX/i
			hash[:concepto] = 9017
		else
			hash[:concepto] = 9000
		end
		if hash[:id_ti_valor2] =~ /(CLP|USD)/
			hash[:id_ti2] = "Currency"
		end
		hash[:id_ti_valor1] = hash[:id_ti_valor1].gsub(/\(.+$/,"")
		hash
	end
end

class PER::CashTransactionTable < CashTransactionTable

	def pre_load *args
		super
		@label_index = 		5
		@title_limit = 		3
		@row_limit = 		1
		@cash_curr = 		"USD"
	end

	def get_results
		new_movements = []					#To store new positions
		label = nil  						#Multiline titles
		present = get_table do |table|							#Iteration over each table until bottom
			table.rows.reverse_each.with_index do |row, i|		#Iteration over each table row
				results = table.headers.map {|h| h.results[-i-1].result} 		#Row results
				each_result_do results, row
				new_title = results[label_index]
				new_title = (new_title.nil? or new_title.empty? or new_title == Result::NOT_FOUND) ?
				 nil : new_title				#Set title if any
				label = new_title if new_title	#Set label unless it's old
				
				movement = new_movement(results)
				if movement
					movement.detalle << "[#{label}]" 
					new_movements << movement 
				end
			end
		end
		if present
			return new_movements
		else
			puts "#{name} table missing #{@reader}" if verbose
			return nil
		end
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
		if options.select{|o| o =~ /\(continuación\)/}.any? or options.empty?
			return Result::NOT_FOUND 
		else
			text = options.select{|o| 
				not o.empty? and
				o =~ /.*[A-Z]{2}.*/ and
				not (o =~ /(Rédito|Fondo\s?de\s?Money^\s*$)/)
			}.each{|o| o.strip!}.join(';')
			return text.empty? ? Result::NOT_FOUND : text
		end
	end

	def check_results new_positions
		if new_positions.empty?
			puts "EMPTY TABLE".yellow
			return []
		end 
		total_i = pre_check_do new_positions
		puts "Pre-Check  reader #{@reader}" if verbose
		table_total = (total and total.execute(@reader)) ? BankUtils.to_number(total.results[total_index].result, spanish) : nil
		#table_total *= @@alt_currs[@alt_currency.to_sym] if table_total and @alt_currency
		total.print_results if verbose and table_total
		puts "Post-Check reader #{@reader}" if verbose
		acumulated = 0
		new_positions.map{|p| acumulated += p.value}
		BankUtils.check acumulated, table_total - total_i
		return new_positions
	end
end

Dir[File.dirname(__FILE__) + '/*/TransactionTables/*.rb'].each {|file| require_relative file } 
