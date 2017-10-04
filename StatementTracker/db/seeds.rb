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
noticed_status.update(description: "Cartola ha llegado al repositorio.")
read_status = StatementStatus.where(
	code: 110, 
	progress: 60,
	message: "Leído"
	).first_or_create
read_status.update(description: "Cartola fue leída correctamente y conciliada en Checkmov")
uploaded_status = StatementStatus.where(
	code: 120, 
	progress: 70,
	message: "Subido"
	).first_or_create
uploaded_status.update(description: "Posición y Movimientos subidos al sistema")
balanced_status = StatementStatus.where(
	code: 130, 
	progress: 80,
	message: "Conciliado"
	).first_or_create
balanced_status.update(description: "Cartola ajustada y cuadre entre movimientos, posición y precios")
processed_status = StatementStatus.where(
	code: 140, 
	progress: 99,
	message: "Procesado"
	).first_or_create
processed_status.update(description: "Cartola procesada y revisada")
archived_status = StatementStatus.where(
	code: 200, 
	progress: 100,
	message: "Archivado"
	).first_or_create
archived_status.update(description: "Cartola archivada después de ser usada")

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
gs = Bank.where(
	name: "Goldman Sachs",
	code_name: "GS",
	folder_name: "GS"
	).first_or_create
jp = Bank.where(
	name: "JP Morgan",
	code_name: "JPM",
	folder_name: "JPM"
	).first_or_create
itau = Bank.where(
	name: "Itau",
	code_name: "ITAU",
	folder_name: "ITAU"
	).first_or_create
mbi = Bank.where(
	name: "MBI",
	code_name: "MBI",
	folder_name: "MBI"
	).first_or_create
lv = Bank.where(
	name: "Larraín Vial",
	code_name: "LV",
	folder_name: "LV"
	).first_or_create
btg = Bank.where(
	name: "BTG Pactual",
	code_name: "BTG",
	folder_name: "BTG"
	).first_or_create
san = Bank.where(
	name: "Santander",
	code_name: "SANT",
	folder_name: "SANT"
	).first_or_create
cds = Bank.where(
	name: "Cruz del Sur",
	code_name: "CDS",
	folder_name: "CDS"
	).first_or_create
ea = Bank.where(
	name: "Euroamérica",
	code_name: "EA",
	folder_name: "EA"
	).first_or_create
bci = Bank.where(
	name: "BCI",
	code_name: "BCI",
	folder_name: "BCI"
	).first_or_create
citi = Bank.where(
	name: "Citi",
	code_name: "CITI",
	folder_name: "CITI"
	).first_or_create
ml = Bank.where(
	name: "Merryl Lynch",
	code_name: "ML",
	folder_name: "ML"
	).first_or_create
volcom = Bank.where(
	name: "Volcom",
	code_name: "Volcom",
	folder_name: "Volcom"
	).first_or_create
ap = Bank.where(
	name: "Acceso Partners",
	code_name: "AP",
	folder_name: "AP"
	).first_or_create
bice = Bank.where(
	name: "BICE",
	code_name: "BICE",
	folder_name: "BICE"
	).first_or_create


ubs = Bank.where(
	name: 'UBS',
	code_name: 'UBS',
	folder_name: 'UBS'
	).first_or_create
celf = Bank.where(
	name: 'Celfin',
	code_name: 'CELF',
	folder_name: 'CELF'
	).first_or_create
fid = Bank.where(
	name: 'Fidelity',
	code_name: 'FID',
	folder_name: 'FID'
	).first_or_create

Society.where(name: "Portfolio Capital (1)").first_or_create

Synonym.where(label: "Mstanley".strip.titleize, listable: ms).first_or_create
Synonym.where(label: "M Stanley".strip.titleize, listable: ms).first_or_create
Synonym.where(label: "Morgan S".strip.titleize, listable: ms).first_or_create
Synonym.where(label: "Hsbc".strip.titleize, listable: hsbc).first_or_create
Synonym.where(label: "Security".strip.titleize, listable: sec).first_or_create
Synonym.where(label: "CrediCorp".strip.titleize, listable: corp).first_or_create
Synonym.where(label: "Moneda".strip.titleize, listable: mon).first_or_create
Synonym.where(label: "Pershing".strip.titleize, listable: per).first_or_create
Synonym.where(label: "Persh".strip.titleize, listable: per).first_or_create
Synonym.where(label: "Banchile".strip.titleize, listable: bc).first_or_create
Synonym.where(label: "Bch".strip.titleize, listable: bc).first_or_create
Synonym.where(label: 'Goldman'.strip.titleize, listable: gs).first_or_create
Synonym.where(label: 'Sachs'.strip.titleize, listable: gs).first_or_create
Synonym.where(label: 'JP'.strip.titleize, listable: jp).first_or_create
Synonym.where(label: 'JPMorgan'.strip.titleize, listable: jp).first_or_create
Synonym.where(label: 'Itau'.strip.titleize, listable: itau).first_or_create
Synonym.where(label: 'Larrain Vial'.strip.titleize, listable: lv).first_or_create
Synonym.where(label: 'Euroamerica'.strip.titleize, listable: ea).first_or_create
Synonym.where(label: 'Acceso Partner'.strip.titleize, listable: ap).first_or_create

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
