require_relative "MedCare.rb"
class Colmena < Medcare

	GLOBAL_OFFSET = [10,0,0,0]

	DIR = "Colmena"

	def dir
		DIR
	end

	module Custom
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'(100|[1-9]?\d)(\,\d{1,3}){0,1}%(\(\*\))?'
		when Setup::Type::AMOUNT
			'([$]?[0-9]{1,3}(?:.[0-9]{3})*(\,[0-9]{1,3})?|SIN TOPE){1}'
		when Setup::Type::INTEGER
			'\(?\d{1,2}\)?'
		when Setup::Type::LABEL
			'.+'
		end
	end

	private  

		def analyse_position file
			puts "ANALYSING #{file}"
			@reader = Reader.new(file)
			@accounts = []
			@accounts.concat(get_accounts("HOSPITALARIA", 
									["PARTO NORMAL",
									"PARTO POR CESAREA",
									"APENDICENTOMIA",
									"COLECISTECTOMIA POR VIDEOLAPAROSCOPIA",
									"HISTERECTOMIA TOTAL",
									"AMIGDALECTOMIA",
									"CIRUGIA CARDIACA DE COMPLEJIDAD MAYOR",
									"EXTIRPACION DE TUMOR Y/O QUISTE ENCEFALICO",
									"DIAS CAMA",
									"MEDICAMENTOS Y MAT. CLINICOS, Para los siguientes eventos:"]))
			@accounts.concat(get_accounts("AMBULATORIA", 
									["CONSULTAS",
									"EXAMENES Y PROCEDIMIENTOS",
									"IMAGENOLOGIA",
									"MEDICINA FISICA"]))
			@accounts.each.with_index do |account, i|
				puts "\nACC: #{account.name}"
				bottom = @accounts.size == i+1 ? "etas al siguiente tope anual" : @accounts[i+1].name
				analyse_prices account, bottom
			end
		end

		def get_accounts category, titles
			accounts = []
			titles.each.with_index do |title, i|
				accounts << AccountColmena.new(title, category)
			end
			accounts
		end

		def analyse_prices account, bottom
			print "Proccesing prices ... "
			table_end = Field.new(bottom)
			headers = []
			headers << HeaderField.new(@accounts.first.name, headers.size, Setup::Type::LABEL, true, 4, Setup::Align::BOTTOM_LEFT)
			headers << HeaderField.new("% DE BONIFICACIÓN", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new("TOPE", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("% DE BONIFICACIÓN", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new("TOPE", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("COPAGO", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new("Nº CONVENIO", headers.size, Setup::Type::INTEGER, false)
			offset = Field.new(account.name)
			table = Table.new(headers, Field.new(bottom), offset)
			table.execute @reader
			table.print_results
			
			@reader.go_to 1
			table.rows.each.with_index do |row, i|
				results = table.headers.map{|h| h.results[i].result}
				results = clear_not_found results
				account.elements << Record.new(results[0], clean(results[1]), results[2], clean(results[3]), results[4])
			end
		end

		def clean percentage
			return "" if percentage.nil?
			percentage.delete('*').delete('(').delete(')').strip
		end
		def clear_not_found results
			results.map{|r| r == Result::NOT_FOUND ? "" : r}
		end
end