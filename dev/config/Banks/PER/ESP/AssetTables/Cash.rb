class PER::ESP::Cash < PER::AssetTable
	def load
		@name = "cash"
		@offset = Field.new("Money Market")
		@table_end = Field.new("TOTAL DE EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS")
		@headers = []
			headers << HeaderField.new("Fecha inicial",headers.size, Setup::Type::DATE)
			headers << HeaderField.new("Cantidad",headers.size, Custom::NUM3, true)
			headers << HeaderField.new("Número de Cuenta",headers.size, Setup::Type::LABEL)
			headers << HeaderField.new(["Actividades","Finalizando el"],headers.size, Setup::Type::DATE,false,4)
			headers << HeaderField.new(["Saldo","de Apertura"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Saldo","al Cierre"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos","Devengados"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos","en este Año"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Rédito a","30 Días"],headers.size, Setup::Type::PERCENTAGE,false,4)
			headers << HeaderField.new(["Rédito","Actual"],headers.size, Setup::Type::PERCENTAGE,false,4)
		@total = SingleField.new("TOTAL DE EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS",
			BankUtils.to_arr(Setup::Type::AMOUNT,4))
		@page_end = 		Field.new("Página ¶¶ de ")
		@price_default = 	"1.0"
		@quantity_index = 	5
		@value_index = 		5
		@total_index = 		1
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		1
	end

	def parse_position str, type
		[str,"Cash"]
	end
end

class PER::ESP::CashAlt < PER::ESP::Cash
	def load
		@name = "cash alt"
		@offset = Field.new("Money Market")
		@table_end = Field.new("TOTAL DE EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS")
		@headers = []
			headers << HeaderField.new("Descripción",headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cantidad",headers.size, Custom::NUM3, true)
			headers << HeaderField.new(["Saldo","de Apertura"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Saldo","al Cierre"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos","Devengados"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos en","este Año"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Rédito a","30 Días"],headers.size, Setup::Type::PERCENTAGE,false,4)
		@total = SingleField.new("TOTAL DE EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS",
			BankUtils.to_arr(Setup::Type::AMOUNT,4))
		@page_end = 		Field.new("Página ¶¶ de ")
		@label_index = 		0
		@price_default = 	"1.0"
		@quantity_index = 	3
		@value_index = 		3
		@total_index = 		1
		@require_rows = 	true
		@require_offset = 	true
		@row_limit = 		1
	end

	def each_result_do results, row=nil
		results[label_index].strip
	end
end

class PER::ESP::CashEmpty < PER::ESP::Cash
	def load
		super
		@name = "cash no money market"
		@offset = Field.new("EFECTIVO, FONDOS DE DINERO Y DEPÓSITOS BANCARIOS")
		@headers = []
			headers << HeaderField.new("Fecha inicial",headers.size, Custom::NO_MM_DATE, true)
			headers << HeaderField.new("Cantidad",headers.size, Setup::Type::AMOUNT)
			headers << HeaderField.new("Número de Cuenta",headers.size, Setup::Type::BLANK)
			headers << HeaderField.new(["Actividades","Finalizando el"],headers.size, Setup::Type::DATE,false,4)
			headers << HeaderField.new(["Saldo","de Apertura"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Saldo","al Cierre"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos","Devengados"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Ingresos","en este Año"],headers.size, Custom::NUM2,false,4)
			headers << HeaderField.new(["Rédito a","30 Días"],headers.size, Setup::Type::PERCENTAGE,false,4)
			headers << HeaderField.new(["Rédito","Actual"],headers.size, Setup::Type::PERCENTAGE,false,4)
		@label_index = 		0
	end

	def each_result_do results, row=nil
		if results[label_index] =~ /\d{2}(\/\d{2}){2}/
			return super(results, row)
		else
			results[label_index].strip
		end
	end
end



