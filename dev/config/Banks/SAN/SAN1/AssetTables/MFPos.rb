class SAN1::MFPos < SAN1::AssetTable
	def load
		@name = "SALDOS"
		@table_end = Field.new("SALDO FINAL")
		@headers = []
			headers << HeaderField.new("Fondo Mutuo",headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Serie",headers.size, Setup::Type::LABEL)
			headers << HeaderField.new("Cuenta",headers.size, Setup::Type::INTEGER)
			headers << HeaderField.new("Acogido",headers.size, Setup::Type::BLANK)
			headers << HeaderField.new("Total Cuotas",headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Valor Cuota del día",headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Total",headers.size, Setup::Type::AMOUNT, true)
			headers << HeaderField.new("Total Cuotas",headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Valor Cuota del día",headers.size, SAN1::Custom::FLOAT4)
			headers << HeaderField.new("Total",headers.size, Setup::Type::AMOUNT)
		@total = SingleField.new("SALDO FINAL",
			[Setup::Type::AMOUNT, SAN1::Custom::FINAL_PAT, Setup::Type::AMOUNT])
		@page_end = 		Field.new("En caso de no estar conforme con alguna información")
		@label_index = 		0
		@price_index = 		8
		@quantity_index = 7
		@value_index = 		9
		@total_index = 		2
	end
end