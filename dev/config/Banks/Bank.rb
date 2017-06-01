require_relative 'BankUtils.rb'
# Abstract bank class never to be instantiated
class Bank < Institution

	# Accounts to store information
	attr_accessor :accounts
	attr_reader :date_out
	attr_accessor :total_out
	attr_reader :usd_value

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

MESES = [[1, /ene/i],
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
		file.write("concepto;
			fecha_movimiento;
			fecha_pago;
			Monto Comision;
			Moneda Comision;
			factura;
			precio;
			id_ti_valor1;
			id_ti1;
			id_sec1;
			id_fi1;
			cantidad1;
			id_ti_valor2;
			id_ti2;
			id_sec2;
			id_fi2;
			cantidad2;
			detalle\n")
		accounts.reverse_each do |acc|
			acc.movements.each do |mov|
				file.write(mov.print)
			end
		end
	end

end

