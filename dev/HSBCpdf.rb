require 'rubygems'
require 'pdf/reader'

receiver = PDF::Reader::RegisterReceiver.new

#archivos = Dir["/Users/Jose Antonio/Dropbox/Maul-Peters/Quaam/Operaciones/004 Clientes/Clientes Portfolio Cap/Familia Farcas/DAC/HSBC/*.pdf"]
#archivos = Dir["/Users/juanse/Desktop/Cartolas/RawDataTests/HSBC/2014/*.pdf"]
#archivos = Dir["/Users/windows7/Desktop/Cartolas/*.pdf"]
archivos = Dir["test_cases/*.pdf"]

#Metodos funcionales

$numbers = []
$separador = ""
#Metodos funcionales

#Metodo que identifica si la cartola usa separador decimal de punto o coma
def identificarSeparador(valores)

	for i in 0 .. valores.length - 1
		if not valores[i] =~ /[A-Z]/
			puntos = valores[i].scan('.').count
			comas = valores[i].scan(',').count
			#puts valores[i]
			#puts puntos
			#puts comas
			if puntos > 1
				$separador = "."
				puts "separador: #{$separador}"
				break
			elsif comas > 1
				$separador = ","
				puts "separador: #{$separador}"
				break
			end

			if puntos == 1 and comas == 1
				if valores[i].index(',') < valores[i].index('.')
					$separador = ","
					break
				elsif  valores[i].index(',') > valores[i].index('.')
					$separador = "."
					break				
				end
			elsif puntos == 1
				unless valores[i].length - valores[i].index('.') == 3
					$separador = ","
					break
				end

			elsif comas == 1				
				unless valores[i].length - valores[i].index(',') != 3
					$separador = "."
					break
				end
			end

		end
	end

end
#Convierte un string a un numero de punto flotante (Con separador numerico de punto, y decimal de coma)
def numerize(value)
	if not (value == nil or value == "")

		if $separador == ','
			if value.include? '.'
				value = value.gsub('.','*')
			end
			if value.include? ','
				value = value.gsub(',','')
			end
			if value.include? '*'
				value = value.gsub('*','.')
			end
		end
	end
	
	return value.to_f
end

#Metodo que checkea si una linea contiene un valor negativo, y retorna el valor numerico
def checknegativity(value)

	aux_string = value.partition('(').last
	if aux_string.include? "(" or aux_string.include? "\\"
		negativo = true
	end

	number = value.scan(/[-+]?[0-9]*[,.]?[0-9]*[,.]?[0-9]+[,.]?[0-9]+[,.]?[0-9]+/)[0]
	number = numerize(number)
	if negativo
		number = number*-1
	end
	return number
end
 
#Metodo que retorna true si una linea corresponde a una fecha
def check_if_LineisDate(line)

	aux_array = line.split("/")


	if aux_array.length != 3
		return false
	end

	if aux_array[0].length != 2 and aux_array[1].length != 2 and aux_array[2].length != 4
		return false
	end
	

	return true

end

# pos[0] = instrumento; pos[1] = cantidad; pos[2] = precio; pos[3] = monto; pos[4] = datos extra
def processPosition(posicion, type)

	pos = []

	#Identificar si la cartola usa separador decimal de punto o coma
	if $numbers.length == 0
		for j in 0 .. posicion.length - 1
			$numbers.push(posicion[j])
		end
		identificarSeparador($numbers)
		#puts $separador
	end

	if type == "LIQUID ASSET"

		pos[0] = pos[0].to_s

		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i >= 2 and i <= 3
				pos[0] += " " + posicion[i]
			end
		end

		pos[0] = pos[0].strip
		pos[1] = numerize(posicion[1])
		pos[3] = numerize(posicion[5])

		pos[2] = pos[3]/pos[1]

	elsif type == "FIXED INCOME"

		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			#puts posicion[i]
		end
		#puts posicion
		#puts "******"
		index = 0
		if posicion.length >= 18 and not posicion[4] =~ /[A-Z]/
			index = -1
		end
		if posicion[5] =~ /[A-Z]/
			index += 1
		end
		#Instrumento
		#pos[0] = posicion[1] + " " + posicion[2] + " " + posicion[3] + " " + posicion[4]
		pos[0] = posicion[1..4].join(" ")
		#Cantidad
		pos[1] = numerize(posicion[7 + index])
		#Precio
		pos[2] = numerize(posicion[5 + index])
		#Monto
		pos[3] = numerize(posicion[9 + index])

	elsif type == "EQUITY MF"

		extra_index = 0	

		if posicion.length == 16
			extra_index = 1
			if posicion[posicion.length - 1] == "2"
				posicion.delete_at(posicion.length - 1)
				extra_index = 0
				#puts posicion
			end
		end
		#puts posicion
		#puts "******"
		#if posicion.length == 17
		#	if posicion.length
		#	posicion.delete_at(0)
		#	extra_index = 0
		#end

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i >= 1 and i <= (3 + extra_index)
				pos[0] += " " + posicion[i]
			end
		end
		#Instrumento
		pos[0] = pos[0].strip
		#puts pos[0]
		#Cantidad
		pos[1] = numerize(posicion[6 + extra_index])
		#Precio
		pos[2] = numerize(posicion[4 + extra_index])
		#Monto
		pos[3] = numerize(posicion[8 + extra_index])

	elsif type == "ALTERNATIVE INVESTMENT"

		extra_index = 0

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i >= 2 and i <= 4
				pos[0] += " " + posicion[i]
			end
		end
		if posicion[5] =~ /[A-Z]/
			extra_index = 1
		end
		#Instrumento
		pos[0] = pos[0].strip
		#Cantidad
		pos[1] = numerize(posicion[1 + extra_index])
		#Precio
		pos[2] = numerize(posicion[9 + extra_index])
		#Monto
		pos[3] = numerize(posicion[13 + extra_index])

	elsif type == "REAL ESTATE"
		
		extra_index = 0

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i >= 1 and i <= 2
				pos[0] += " " + posicion[i]
			end
		end

		#if posicion[5] =~ /[A-Z]/
		#	extra_index = 1
		#end
		#Instrumento
		pos[0] = pos[0].strip
		#Cantidad
		pos[1] = numerize(posicion[5 + extra_index])
		#Precio
		pos[2] = numerize(posicion[3 + extra_index])
		#Monto
		pos[3] = numerize(posicion[6 + extra_index])		

	elsif type == "MIXED ASSET"
		
		extra_index = 0

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if (i >= 2 and i <= 3) or (i == 4 and posicion[i] =~ /[A-Z]/)
				pos[0] += " " + posicion[i]
			end
		end

		if posicion[4] =~ /[A-Z]/
			extra_index = 1
		end
		if posicion.length == 13 or posicion.length == 15
			extra_index = 2
		end
		#puts posicion.length
		#Instrumento
		pos[0] = pos[0].strip
		#Cantidad
		pos[1] = numerize(posicion[1])
		#Precio
		pos[2] = numerize(posicion[6 + extra_index])
		#Monto
		pos[3] = numerize(posicion[7 + extra_index])

	elsif type == "PRIVATE EQUITY"
		
		extra_index = 0

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i == 2 or (i == 3 and posicion[i] =~ /[A-Z]/)
				pos[0] += " " + posicion[i]
			end
		end

		if posicion[3] =~ /[A-Z]/
			extra_index = 1
		end
		
		#Instrumento
		pos[0] = pos[0].strip
		#Cantidad
		pos[1] = numerize(posicion[1])
		#Precio
		pos[2] = numerize(posicion[6 + extra_index])
		#Monto
		pos[3] = numerize(posicion[4 + extra_index])

	elsif type == "FOREIGN EXCHANGE"
		
		extra_index = 0

		pos[0] = pos[0].to_s
		#Sacar espacios de las lineas que corresponden al nombre (vienen como arreglo con datos entre medio) (posicion[1-4])
		for i in 1 .. posicion.length - 1 #(3 + extra_index)
			aux_string = posicion[i].split('(')
			posicion[i] = ""
			for j in 0 .. aux_string.length - 1
				if aux_string[j].include? ')'
					posicion[i] += aux_string[j][0, aux_string[j].index(')')]
				else
					posicion[i] += aux_string[j]
				end
			end
			#posicion[i] += aux_string[aux_string.length - 1]
			if i == 8
				pos[0] += " " + posicion[i]
			end
		end
		
		#Instrumento
		pos[0] = pos[0].strip
		#Cantidad
		pos[1] = numerize(posicion[11])
		#Precio
		pos[2] = numerize(posicion[3])
		#Monto
		pos[3] = numerize(posicion[6])
	end

	for i in 0 .. 3
		pos[i] = pos[i].to_s
		if pos[i].include? '.'
			pos[i] = pos[i].gsub('.',',')
		end
	end
	pos[0] = pos[0].strip
	return pos


end

$contador_movimientos = 0

archivos.each do |archivo|
	$contador_movimientos = 0
	#variables globales por archivo
	total_portfolio = 0	#Asignado
	fecha = ""				#Asignado
	pais = "CL"
	tipo_tax = "RUT"
	id_tax = "12345"
	id_fil1 = "HSBC"
	id_ti_valor2 = "Currency"
	id_ti2 = "CLP"
	$numbers = []
	$separador = ""

	#Variables de cada cuenta
	id_sec1 = ""  #ID_sec1 = codigo de la cuenta (EJ: 654-018086-104 para Select UMA Active Assets account) - Asignado
	caja = ""

	aux = 0
	formato = 0
	$aux_element = []
	$aux_cont = 0


	reader = PDF::Reader.new(archivo)
	f_pos = File.open("#{archivo[0, archivo.length-4]}_pos.txt",'w')
	f_mov = File.open("#{archivo[0, archivo.length-4]}_mov.txt",'w')

	f_pos.write("Pais_tax;Tipo_tax;Id_tax;Id_sec1;Id_fi1;Fecha;Instrumento;Cantidad;Precio;Monto;Datos Adicionales" + "\n")
	f_mov.write("Pais_tax;Tipo_tax;Id_tax;Concepto;Fecha mov;Fecha pago;Monto comision;Moneda comision;Factura;Precio;Id_ti_valor1;Id_ti1;Id_sec1;Id_fi1;Cantidad1;Id_ti_valor2;Id_ti2;Id_sec2;Id_fi2;Cantidad2;Comentarios" + "\n")

	#De la segunda pagina sacar los datos de cuenta, fecha y total
	reader.page(2).raw_content.each_line do |line|

		if (formato == 1 or formato == 2 or formato == 3 or formato == 4 or formato == 5) and (line =~/TJ/ or line =~ /\(E&O/)
			aux += 1
		end

		#Total portfolio
		if line =~ /\(NET \) 30 \(ASSETS\)/
			formato = 1
			aux = 0
		end
		if formato == 1 and aux == 1 and line =~ /TJ$/
			total_portfolio = line[line.index('(') + 1, line.index(')') - 2]
			puts total_portfolio
		end

		#Fecha y num cuenta
		if line =~ /\[\(1 of/
			formato = 2
			aux = 0
		end
		if formato == 2 and aux == 1 and (line =~ /TJ$/ or line =~ /\(E&O/)
			puts line
			if line =~ /\) 14 \(/
				aux_array = line.split('(')

				#Fecha
				fecha = aux_array[1].partition(')').first + aux_array[2].partition(')').first
				puts fecha

				#Num cuenta
				id_sec1 = aux_array[4].scan(/[0-9]+/)[0]
				puts id_sec1
			else
				aux_array = line.split('(')
				#Fecha
				aux_i = aux_array[1].index(')') ? aux_array[1].index(')') : aux_array[1].size
				fecha = aux_array[1][0, aux_i - 3]
				puts fecha

				#Num cuenta
				id_sec1 = aux_array[2] ? aux_array[2].scan(/[0-9]+/)[0] : "ide_sec1"
				puts id_sec1
			end

		end

	end

	reader.pages.each do |page|
		formato = 0
		aux = 0
		pos = [] # pos[0] = instrumento; pos[1] = cantidad; pos[2] = precio; pos[3] = monto; pos[4] = datos extra
		mov = []

		if (page.raw_content["(LIQUID ) 45 (ASSETS"] or page.raw_content["(Liquid ) 45 (Assets"]) and page.raw_content["(Qty) 60 (. / Balance)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []
			
			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(CURRENT\) 14 \( \) 45 \(ACCOUNTS\)/ or line =~ /\(Current \) 45 \(Accounts\)/
					formato = 1
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( LIQUID \) 30 \(ASSETS\)/ or line =~ /\(T\) 60 \(otal Liquid \) 30 \(Assets\)/
					formato = 5
					#puts aux_pos
					#puts "*********"
					#pos = processPosition(aux_pos, "RENTA VARIABLE")
					#f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					#aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					
					if aux_string =~ /%/
						contador += 1
					end

					if contador < 2
						aux_pos.push(aux_string)

					else
						aux_pos.push(aux_string)
						#puts aux_pos
						#puts "*********"
						pos = processPosition(aux_pos, "LIQUID ASSET")
						f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
						aux_pos = []
						contador = 0
					end
				end
			end
		end

		if (page.raw_content["(FIXED INCOME"] or page.raw_content["(Fixed Income"]) and page.raw_content["(Qty) 60 (. / Nominal)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []
			#puts page.number
			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(FIXED INCOME MUTUAL\) 30 \( FUNDS\)/ or line =~ /\(Fixed Income Mutual Funds\)/  or line =~ /\(BONDS\)/ or line =~ /\(Bonds\)/ or line =~ /\(Convertible Bonds Mutual Funds\)/
					formato = 1
					aux = 0
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( FIXED INCOME\)/ or line =~ /\(T\) 60 \(otal Fixed Income\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					pos = processPosition(aux_pos, "FIXED INCOME")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					if aux_string == "USD" or aux_string == "EUR" or aux_string == "JPY" or aux_string == "CAD"
						contador += 1
					end
					if not (line =~ /\(USA\)/ or line =~ /\(Europe\)/ or line =~ /\(Emerging\)/ or line =~ /\(Global\)/ or line =~ /\(Asia\)/ or line =~ /\(Japan\)/ or line =~ /\(Others\)/)
						if contador < 2
							aux_pos.push(aux_string)

						else
							#puts aux_pos.length
							#puts "*********"
							pos = processPosition(aux_pos, "FIXED INCOME")
							f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
							aux_pos = []
							aux_pos.push(aux_string)
							contador = 1
						end
					end
				end
			end
			
		end

		if (page.raw_content["(EQUITIES"] or page.raw_content["(Equities"]) and page.raw_content["(Qty) 60 (.)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(EQUITY\) 14 \( MUTUAL\) 30 \( FUNDS\)/ or line =~ /\(Equity Mutual Funds\)/ or line =~ /\(Equity Linked Notes\)/ or line =~ /\(EQUITY\) 14 \( LINKED NOTES 2/
					formato = 1
					aux = 0
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( EQUITY\)/ or line =~ /\(T\) 60 \(otal Equity\)/  or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					pos = processPosition(aux_pos, "EQUITY MF")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					if aux_string == "USD" or aux_string == "EUR" or aux_string == "JPY" or aux_string == "CAD"
						contador += 1
					end

					if not (line =~ /\(USA\)/ or line =~ /\(Europe\)/ or line =~ /\(Emerging\)/ or line =~ /\(Global\)/ or line =~ /\(Japan\)/ or line =~ /\(Others\)/)
						if contador < 2
							aux_pos.push(aux_string)

						else
							if aux_pos.length > 8
								#puts aux_pos
								#puts "*********"
								pos = processPosition(aux_pos, "EQUITY MF")
								f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
								aux_pos = []
								aux_pos.push(aux_string)
								contador = 1
							else
								contador -= 1
							end
						end
					end
				end
			end
			
		end

		if (page.raw_content["(AL) 60 (TERNA) 60 (TIVE INVESTMENTS"] or page.raw_content["(Alternative Investments"]) and page.raw_content["(Qty) 60 (. / Balance)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(AL\) 60 \(TERNA\) 60 \(TIVE FUNDS\)/ or line =~ /\(Alternative Funds\)/
					formato = 1
				end
				if line =~ /T\) 14 \(OT\) 60 \(AL\) 14 \( \) 30 \(AL\) 60 \(TERNA\) 60 \(TIVE INVESTMENTS/ or line =~ /\(T\) 60 \(otal \) 30 \(Alternative Investments\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					pos = processPosition(aux_pos, "ALTERNATIVE INVESTMENT")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					
					if aux_string == "USD"
						contador += 1
					end
					if not line =~ /\(Fund of Funds\)/
						if contador < 2
							aux_pos.push(aux_string)

						else
							#puts aux_pos
							#puts "*********"
							pos = processPosition(aux_pos, "ALTERNATIVE INVESTMENT")
							f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
							aux_pos = []
							aux_pos.push(aux_string)
							contador = 1
						end
					end
				
				end
			end
			
		end

		if (page.raw_content["(REAL) 30 ( EST) 60 (A) 60 (TE"] or page.raw_content["(Real Estate"]) and page.raw_content["(Cur) 45 (.)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(REAL\) 30 \( EST\) 60 \(A\) 60 \(TE FUNDS\)/ or line =~ /\(Real Estate Funds\)/
					formato = 1
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( REAL\) 14 \( EST\) 60 \(A\) 60 \(TE\)/ or line =~ /\(T\) 60 \(otal Real Estate\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					pos = processPosition(aux_pos, "REAL ESTATE")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					
					if aux_string == "USD"
						contador += 1
					end

					if contador < 2
						aux_pos.push(aux_string)

					else
						#puts aux_pos
						#puts "*********"
						pos = processPosition(aux_pos, "REAL ESTATE")
						f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
						aux_pos = []
						aux_pos.push(aux_string)
						contador = 1
					end
				
				end
			end
			
		end

		if (page.raw_content["(MIXED ) 45 (ASSET) 14 ( CLASS"] or page.raw_content["(Mixed ) 45 (Asset Class"]) and page.raw_content["(Qty) 60 (. / Balance)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(DISCRETIONAR\) 14 \(Y\) 14 \( MANDA\) 60 \(TES\)/ or line =~ /\(Discretionary Mandates\)/
					formato = 1
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( MIXED \) 30 \(ASSET CLASS\)/ or line =~ /\(T\) 60 \(otal Mixed \) 30 \(Asset Class\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					puts aux_pos
					puts "*********"
					pos = processPosition(aux_pos, "MIXED ASSET")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					
					if aux_string == "USD"
						contador += 1
					end
					if not (line =~ /\(USA\)/ or line =~ /\(Europe\)/ or line =~ /\(Emerging\)/ or line =~ /\(Global\)/)

						if contador < 2
							aux_pos.push(aux_string)

						else
							puts aux_pos
							puts "*********"
							pos = processPosition(aux_pos, "MIXED ASSET")
							f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
							aux_pos = []
							aux_pos.push(aux_string)
							contador = 1
						end
					end
				
				end
			end
			
		end
		if (page.raw_content["(PRIV) 60 (A) 60 (TE EQUITY)"] or page.raw_content["(Private Equity"]) and page.raw_content["(Qty) 60 (. / Balance)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(PRIV\) 60 \(A\) 60 \(TE EQUITY\) 14 \( FUNDS\)/ or line =~ /\(Private Equity Funds\)/
					formato = 1
				end
				if line =~ /\(T\) 14 \(OT\) 60 \(AL\) 14 \( PRIV\) 60 \(A\) 60 \(TE EQUITY\)/ or line =~ /\(T\) 60 \(otal Private Equity\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					pos = processPosition(aux_pos, "PRIVATE EQUITY")
					f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					
					if aux_string == "USD"
						contador += 1
					end
					if not (line =~ /\(USA\)/ or line =~ /\(Europe\)/ or line =~ /\(Emerging\)/ or line =~ /\(Global\)/)

						if contador < 2
							aux_pos.push(aux_string)

						else
							#puts aux_pos
							#puts "*********"
							pos = processPosition(aux_pos, "PRIVATE EQUITY")
							f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
							aux_pos = []
							aux_pos.push(aux_string)
							contador = 1
						end
					end
				
				end
			end
			
		end

		if (page.raw_content["(Foreign Exchange ) 14 (T) 30 (ransactions"]) and page.raw_content["(Sell cur) 45 (.)"]
			formato = 0
			aux = 0
			contador = 0
			aux_pos = []
			after_cont = 0

			page.raw_content.each_line do |line|

				if (formato == 1 or formato == 2 or formato == 3) and line =~/TJ/
					aux += 1
				end

				if line =~ /\(Foreign Exchange\)/
					formato = 1
				end
				if line =~ /\(T\) 60 \(otal Foreign Exchange T\) 45 \(ransactions\)/ or line =~ /of/ and aux_pos.length > 0
					formato = 5
					#puts aux_pos
					#puts "*********"
					#pos = processPosition(aux_pos, "FOREIGN EXCHANGE")
					#f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
					#aux_pos = []
				end

				if formato == 1 and aux > 0 and line =~ /TJ/
					aux_string = line[line.index('(') + 1, line.rindex(')') - 2]
					#puts aux_string
					
					if aux_string =~ /%/
						contador += 1
					end

					if contador == 2
						after_cont += 1
					end

					if not (line =~ /\(USA\)/ or line =~ /\(Europe\)/ or line =~ /\(Emerging\)/ or line =~ /\(Global\)/)

						if after_cont < 3
							aux_pos.push(aux_string)

						else
							aux_pos.push(aux_string)
							#puts aux_pos
							#puts "*********"
							pos = processPosition(aux_pos, "FOREIGN EXCHANGE")
							f_pos.write("#{pais};#{tipo_tax};#{id_tax};#{id_sec1};#{id_fil1};#{fecha};#{pos[0]};#{pos[1]};#{pos[2]};#{pos[3]};#{pos[4]}" + "\n")
							aux_pos = []
							
							contador = 0
							after_cont = 0
						end
					end
				
				end
			end
			
		end

	end

	total_portfolio = numerize(total_portfolio).to_s
	if total_portfolio.include? '.'
		total_portfolio = total_portfolio.gsub('.',',')
	end
	f_pos.write(";;;;;;Total;;;#{total_portfolio}")
	f_mov.write(";;;;;;N Movimientos;;;#{$contador_movimientos}")
	f_pos.close
	f_mov.close

end


