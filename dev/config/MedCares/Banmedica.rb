require_relative "MedCare.rb"
class Banmedica < Medcare

	#GLOBAL_OFFSET = [7,0,0,0]
	#TABLE_OFFSET = 50
	HORIZONTAL_SEARCH_RANGE = 10
	TEXT_EXPAND = 0.15

	DIR = "Banmedica"

	def dir
		DIR
	end

	module Custom
	end

	def regex(type)
		case type
		when Setup::Type::PERCENTAGE
			'(\(E\))?(100|[1-9]?\d(\.\d{1,2})?%?)'
		when Setup::Type::AMOUNT
			'▯*([$]?[0-9]{1,3}(?:.[0-9]{3})*(\,[0-9]{1,3})?|Sin Tope){1}'
		when Setup::Type::INTEGER
			'\d{1,2}H?'
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
									"APENDICECTOMIA",
									"COLECISTECTOMIA POR VIDEOLAPAROSCOPIA",
									"HISTEROCTOMIA TOTAL",
									"AMIGDALECTOMIA",
									"CIRUGIA CARDIACA DE COMPLEJIDAD MAYOR",
									"EXTIRPACION DE TUMOR Y/O QUISTE ENCEFALICO Y DE HIPOFISIS",
									"DIAS CAMA",
									"MEDICAMENTOS (B)",
									"MATERIALES CLINICOS (B)"]))
			@accounts.concat(get_accounts("AMBULATORIA", 
									["CONSULTAS MEDICAS",
									"EXAMENES Y PROCEDIMIENTOS",
									"IMAGENOLOGIA",
									"MEDICINA FISICA"]))
			@accounts.each.with_index do |account, i|
				puts "\nACC: #{account.name}"
				bottom = @accounts.size == i+1 ? "Notas" : @accounts[i+1].name
				analyse_prices account, bottom
			end
		end

		def get_accounts category, titles
			accounts = []
			titles.each.with_index do |title, i|
				accounts << Account.new(title, category)
			end
			accounts
		end

		def analyse_prices account, bottom
			puts "Proccesing prices ... "
			Field.new("LIBRE ELECCIÓN").execute @reader
			headers = []
			headers << HeaderField.new(@accounts.first.name, headers.size, Setup::Type::LABEL, true, 4, Setup::Align::BOTTOM_LEFT)
			headers << HeaderField.new("%BONIFICACIÓN", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new("TOPE $", headers.size, Setup::Type::AMOUNT, false)
			headers << HeaderField.new("%BONIFICACIÓN", headers.size, Setup::Type::PERCENTAGE, false)
			headers << HeaderField.new("TOPE $", headers.size, Setup::Type::AMOUNT, false)
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
			percentage.to_s.strip << "%" unless percentage.empty?
		end
		def clear_not_found results
			clear = results.map{|r| r == Result::NOT_FOUND ? "" : r}
			clear.map{|r| r.delete('▯')}
		end
end