# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }]).first_or_create
#   Character.create(name: 'Luke', movie: movies.first).first_or_create

#StatementStatus
noticed_status = StatementStatus.where(
	code: 100, 
	progress: 20,
	message: "Recibido"
	).first_or_create
index_status = StatementStatus.where(
	code: 110, 
	progress: 60,
	message: "Leído"
	).first_or_create
indexed_status = StatementStatus.where(
	code: 120, 
	progress: 70,
	message: "Subido"
	).first_or_create
indexed_status = StatementStatus.where(
	code: 130, 
	progress: 80,
	message: "Conciliado"
	).first_or_create
indexed_status = StatementStatus.where(
	code: 140, 
	progress: 99,
	message: "Procesado"
	).first_or_create
StatementStatus.where(
	code: 200, 
	progress: 100,
	message: "Archivado"
	).first_or_create

#BANKs
ms = Bank.where(
	name: "Morgan Stanley",
	code_name: "MS",
	folder_name: "MS"
	).first_or_create
hsbc = Bank.where(
	name: "HSBC",
	code_name: "HSBC",
	folder_name: "HSBC"
	).first_or_create
sec = Bank.where(
	name: "Security",
	code_name: "SEC",
	folder_name: "SEC"
	).first_or_create
corp = Bank.where(
	name: "CrediCorp",
	code_name: "CrediCorp",
	folder_name: "CORP"
	).first_or_create
mon = Bank.where(
	name: "Moneda",
	code_name: "MON",
	folder_name: "MON"
	).first_or_create
per = Bank.where(
	name: "Pershing",
	code_name: "PER",
	folder_name: "PER"
	).first_or_create
bc = Bank.where(
	name: "Banchile",
	code_name: "BC",
	folder_name: "BC"
	).first_or_create
blank = Bank.where(
	name: "Blank",
	code_name: "BLANK",
	folder_name: "BLANK"
	).first_or_create

#Handlers
handler = Handler.where(
	short_name: "Guille",
	repo_path: "/home/finantecdeveloper/gmo/Sandbox/Dropbox",
	local_path: "/Clientes"
	).first_or_create

Synonym.where(label: 'JP', listable: nil).first_or_create
Synonym.where(label: 'JP Morgan', listable: nil).first_or_create
Synonym.where(label: 'JPMorgan', listable: nil).first_or_create
Synonym.where(label: 'JPM', listable: nil).first_or_create
Synonym.where(label: 'Itau', listable: nil).first_or_create
Synonym.where(label: 'MBI', listable: nil).first_or_create
Synonym.where(label: 'LV', listable: nil).first_or_create
Synonym.where(label: 'Larrain Vial', listable: nil).first_or_create
Synonym.where(label: 'BTG', listable: nil).first_or_create
Synonym.where(label: 'BTG Pactual', listable: nil).first_or_create
Synonym.where(label: 'Santander', listable: nil).first_or_create
Synonym.where(label: 'Cruz Del Sur', listable: nil).first_or_create
Synonym.where(label: 'CDS', listable: nil).first_or_create
Synonym.where(label: 'Euroamerica', listable: nil).first_or_create
Synonym.where(label: 'EA', listable: nil).first_or_create
Synonym.where(label: 'BCI', listable: nil).first_or_create
Synonym.where(label: 'Citi', listable: nil).first_or_create
Synonym.where(label: 'ML', listable: nil).first_or_create
Synonym.where(label: 'Merryl Lynch', listable: nil).first_or_create
Synonym.where(label: 'Volcom', listable: nil).first_or_create
Synonym.where(label: 'Acceso Partner', listable: nil).first_or_create
Synonym.where(label: 'BICE', listable: nil).first_or_create
Synonym.where(label: 'UBS', listable: nil).first_or_create
Synonym.where(label: 'Goldman Sachs', listable: nil).first_or_create
Synonym.where(label: 'GS', listable: nil).first_or_create
Synonym.where(label: 'Celfin', listable: nil).first_or_create
Synonym.where(label: 'Fidelity', listable: nil).first_or_create

=begin

#SOCs
null = Society.where(
	name: "INVALID",
	rut: "INVALID",
	).first_or_create
cell = Society.where(
	name: "GRUPO CELL",
	rut: "12.345.678-9",
	).first_or_create
Society.where(
	name: "Celula",
	rut: "12.345.678-9",
	parent: cell
	).first_or_create
Society.where(
	name: "Celular",
	rut: "12.345.678-9",
	parent: cell
	).first_or_create

icafal_1 = Society.where(
	name: "GRUPO ICAFAL",
	rut: "12.345.678-9",
	).first_or_create
icafal_2 = Society.where(
	name: "Falcone",
	rut: "12.345.678-9",
	parent: icafal_1
	).first_or_create
icafal_3 = Society.where(
	name: "7 Alamos",
	rut: "12.345.678-9",
	parent: icafal_2
	).first_or_create

#TAXs
tax_cell_ms = Tax.where(
	bank: ms,
	society: cell,
	periodicity: Tax::MONTHLY,
	quantity: 2
	).first_or_create
tax_cell_hsbc = Tax.where(
	bank: hsbc,
	society: cell,
	periodicity: Tax::MONTHLY,
	quantity: 2
	).first_or_create
tax_icafal_1_sec = Tax.where(
	bank: sec,
	society: icafal_1,
	periodicity: Tax::MONTHLY,
	quantity: 2
	).first_or_create
tax_icafal_2_sec = Tax.where(
	bank: sec,
	society: icafal_2,
	periodicity: Tax::WEEKLY,
	quantity: 2
	).first_or_create
tax_icafal_3_sec = Tax.where(
	bank: sec,
	society: icafal_3,
	periodicity: Tax::DAILY,
	quantity: 2
	).first_or_create

#SEQs
seq_cell_ms = Sequence.where(
	tax: tax_cell_ms,
	year: 2017,
	month: 3,
	).first_or_create



c1 = Statement.where(
    file_name: "cartola_1",
    path: "Cliente1/cartola1.pdf",
    sequence: seq_cell_ms,
    bank: ms,
    handler: handler,
    client: cell,
    d_filed: Date.strptime("03-03-2017","%d-%m-%Y"),
    d_open: Date.strptime("01-02-2017","%d-%m-%Y"),
    d_close: Date.strptime("28-02-2017","%d-%m-%Y"),
    status: index_status,
    file_hash: "cartola_1"
	).first_or_create

5.times do |i|
	Statement.where(
	    file_name: "cartola_#{i+2}",
	    path: "Cliente2/cartola#{i+2}.pdf",
	    client: icafal_1,
	    status: noticed_status,
	    file_hash: "cartola_#{i+2}"
		).first_or_create
end

15.times do |i|
	Statement.where(
	    file_name: "cartola_#{i+7}",
	    path: "Cliente2/cartola#{i+7}.pdf",
	    client: Society.all.order("RANDOM()").take,
	    d_filed: rand(6.month.ago..1.day.ago).to_date,
	    status: noticed_status,
	    file_hash: "cartola_#{i+7}"
		).first_or_create
end

cell_dict = Dictionary.where(
	target: cell,
	identifier: "DEBUG #{cell.name}"
	).first_or_create

icafal_1_dict = Dictionary.where(
	target: icafal_1,
	identifier: "DEBUG #{icafal_1.name}"
	).first_or_create

icafal_2_dict = Dictionary.where(
	target: icafal_2,
	identifier: "DEBUG #{icafal_2.name}"
	).first_or_create

c1_dict = DictionaryElement.where(
	element: c1,
	dictionary: cell_dict
	).first_or_create
=end
