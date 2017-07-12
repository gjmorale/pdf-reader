# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }]).first_or_create
#   Character.create(name: 'Luke', movie: movies.first).first_or_create

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
seq_icafal_sec = Sequence.where(
	tax: tax_icafal_2_sec,
	year: 2017,
	month: 1,
	week: 1
	).first_or_create
seq_icafal_sec = Sequence.where(
	tax: tax_icafal_2_sec,
	year: 2017,
	month: 1,
	week: 2
	).first_or_create
seq_cell_ms = Sequence.where(
	tax: tax_cell_ms,
	year: 2017,
	month: 3,
	).first_or_create
seq_cell_hsbc = Sequence.where(
	tax: tax_cell_hsbc,
	year: 2017,
	month: 3,
	).first_or_create



#Handlers
handler = Handler.where(
	name: "Guillermo Morales",
	short_name: "Guille",
	repo_path: "/home/finantecdeveloper/gmo/Sandbox/Dropbox",
	local_path: "/Clientes"
	).first_or_create

#StatementStatus
StatementStatus.where(
	code: StatementStatus::NOTICED, 
	progress: 10,
	message: "Identificado en BD"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::INDEX, 
	progress: 20,
	message: "Listo para indexar"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::INDEXED, 
	progress: 30,
	message: "Indexado según sociedad"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::READ, 
	progress: 60,
	message: "Leído"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::STAGE, 
	progress: 80,
	message: "Leído e indexado correctamente"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::UPLOAD, 
	progress: 90,
	message: "Lectura ha sido validada en el servidor"
	).first_or_create
StatementStatus.where(
	code: StatementStatus::ARCHIVED, 
	progress: 100,
	message: "Almacenado en sistema de archivos"
	).first_or_create