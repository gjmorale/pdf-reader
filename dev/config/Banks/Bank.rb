# Abstract bank class never to be instantiated
class Bank < Institution

	# Accounts to store information
	attr_accessor :accounts
	attr_reader :date_out
	attr_accessor :total_out

MONTHS = [[1, /jan/i],
		[2, /feb/i],
		[3, /mar/i],
		[4, /apr/i],
		[5, /may/i],
		[6, /jun/i],
		[7, /jul/i],
		[8, /aug/i],
		[9, /sep/i],
		[10, /oct/i],
		[11, /nov/i],
		[12, /dec/i]]

	def set_date value
		month = -1
		MONTHS.each do |m|
			if value =~ m[1]
				month = m[0]
				break
			end
		end
		day = value[value.index('-')+1..value.index(',')-1]
		year = value[value.rindex(' ')+1..-1].strip
		@date_out = "#{day}-#{month}-#{year}"
	end

	def total_s
		@total_out.to_s.sub(".",",")
	end

	def print_results  file
		file.write("Id_sec1;Id_fi1;Fecha;Instrumento;Cantidad;Precio;Monto\n")
		accounts.reverse_each do |acc|
			file.write("#{acc.code};;;Total;;;;#{acc.value_s}\n")
			acc.positions.each do |pos|
				file.write("#{acc.code};#{legacy_code};#{date_out};#{pos.print}")
			end
		end
		file.write(";;;Total;;;;#{total_s}\n")
		#positions = []
		#@accounts.map{|a| positions += a.positions}
		#positions.each do |p|
		#	file.write(p.print)
		#end
	end

end