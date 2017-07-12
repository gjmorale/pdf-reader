class Institution

	# Accounts to store information
	attr_accessor :accounts
	attr_reader :date_out
	attr_accessor :total_out
	attr_reader :usd_value

	MONTHS = [
		[1, /jan/i],
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

	MESES = [
		[1, /ene/i],
		[2, /feb/i],
		[3, /mar/i],
		[4, /abr/i],
		[5, /may/i],
		[6, /jun/i],
		[7, /jul/i],
		[8, /ago/i],
		[9, /sep/i],
		[10, /oct/i],
		[11, /nov/i],
		[12, /dic/i]]

	M_ALL = [MONTHS,MESES].flatten(1)

	# FINE TUNNING parameters:
	# Override in sub-classes for bank specific
	GLOBAL_OFFSET = [0,0,0,0]
	TABLE_OFFSET = 6
	HEADER_ORIENTATION = 8
	VERTICAL_SEARCH_RANGE = 5
	HORIZONTAL_SEARCH_RANGE = 15
	CENTER_MASS_LIMIT = 0.40
	TEXT_EXPAND = 0.5
	SAFE_ZONE = 0
	WILDCHAR = '¶'
	DATE_FORMAT = '\d\d\/\d\d\/\d\d\d\d'

	def self.reset
		@wildchar = nil
		@date_format = nil
		@horizontal_search_range = nil
		@vertical_search_range = nil
		@center_mass_limit = nil
		@text_expand = nil
		@global_offset = nil
		@offset = nil
		@orientation = nil
		@safe_zone = nil
	end
	def wildchar
		@wildchar ||= self.class::WILDCHAR
	end
	def date_format
		@date_format ||= self.class::DATE_FORMAT
	end
	def horizontal_search_range
		@horizontal_search_range ||= self.class::HORIZONTAL_SEARCH_RANGE
	end
	def vertical_search_range
		@vertical_search_range ||= self.class::VERTICAL_SEARCH_RANGE
	end
	def vertical_search_range= value
		@vertical_search_range = value
	end
	def center_mass_limit
		@center_mass_limit ||= self.class::CENTER_MASS_LIMIT
	end
	def text_expand
		@text_expand ||= self.class::TEXT_EXPAND
	end
	def global_offset
		@global_offset ||= self.class::GLOBAL_OFFSET
	end
	def offset
		@offset ||= self.class::TABLE_OFFSET
	end
	def header_orientation
		@orientation ||= self.class::HEADER_ORIENTATION
	end
	def safe_zone
		@safe_zone ||= self.class::SAFE_ZONE
	end

	# Regex format for a specific type.
	# bounded: if it should add start and end of text
	def get_regex(type, bounded = true)
		return Regexp.new('^'<<regex(type)<<'$') if bounded
		return Regexp.new(regex(type))
	end

	#NECESARIO???
	def set_paths in_path, out_path
		@in_path = in_path
		@out_path = out_path
	end

	# Main method be executed
	def run files
		files = files.map{|f| "#{@in_path}/#{dir}/#{f}"}
		files.each do |file|
			dir_path = File.dirname(file)
			dir_name = dir_path[dir_path.rindex('/')+1..-1]
			file_name = file[file.rindex('/')+1..-1]
			puts "\n                                      ".underlined
			print  "~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,~´¨`~,".underlined
			puts " - #{file_name}"
			begin
				analyse_position file
			rescue StandardError => e
				puts e.to_s.red
			end
			unless File.exist? "#{@out_path}/#{dir_name}"
				Dir.mkdir("#{@out_path}/#{dir_name}")
			end
			out = "#{@out_path}/#{dir_name}/#{file_name}_pos.csv"
			print_pos out
			out = "#{@out_path}/#{dir_name}/#{file_name}_mov.csv"
			print_mov out
		end
	end

	# Method to index files instead of full reading
	def index file
		file_name = file[file.rindex('/')+1..-1]
		puts "                                      ".underlined
		print "-.,-´`-.,-´`-.,-´`-.,-´`-.,-´`-.,-´`-.".underlined
		puts " - #{file}"
			soc, date = analyse_index file
			if date =~ /\d+((\/|-)\d+){2}/
				date = date.gsub('/','-')
				date = Date.strptime(date, "%d-%m-%Y")
			end
			return [soc, date]
		begin
		rescue StandardError => e
			puts e.to_s.red
			return [nil, nil]
		end
	end

	def total_s
		@total_out.to_s.sub(".",",")
	end

	def print_pos  out
		file = File.open(out,'w:UTF-8')
		file.write("Id_sec1;Id_fi1;Fecha;Instrumento;Cantidad;Precio;Monto\n")
		accounts.reverse_each do |acc|
			file.write("#{acc.code};;;Total;;;;#{acc.value_s}\n")
			acc.positions.each do |pos|
				file.write("#{acc.code};#{legacy_code};#{date_out};#{pos.print}")
			end
		end
		file.write(";;;Total;;;;#{total_s}\n")
	end

	def print_mov  out
		return unless @accounts.any? {|acc| not acc.movements.nil? and not acc.movements.empty?}
		file = File.open(out,'w:UTF-8')
		file.write("concepto;fecha_movimiento;fecha_pago;Monto Comision;Moneda Comision;factura;precio;id_ti_valor1;id_ti1;id_sec1;id_fi1;cantidad1;id_ti_valor2;id_ti2;id_sec2;id_fi2;cantidad2;detalle\n")
		accounts.reverse_each do |acc|
			acc.movements.each do |mov|
				file.write(mov.print)
			end
		end
	end

end