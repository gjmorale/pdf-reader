# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170731144247) do

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.string   "folder_name"
    t.string   "code_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["code_name"], name: "index_banks_on_code_name", unique: true
    t.index ["folder_name"], name: "index_banks_on_folder_name", unique: true
  end

  create_table "cover_prints", force: :cascade do |t|
    t.string   "first_filter"
    t.string   "second_filter"
    t.integer  "bank_id"
    t.integer  "meta_print_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["bank_id"], name: "index_cover_prints_on_bank_id"
    t.index ["first_filter", "second_filter", "meta_print_id"], name: "cover_filters_index", unique: true
    t.index ["meta_print_id"], name: "index_cover_prints_on_meta_print_id"
  end

  create_table "dictionaries", force: :cascade do |t|
    t.text     "identifier"
    t.string   "target_type"
    t.integer  "target_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["identifier"], name: "index_dictionaries_on_identifier"
    t.index ["target_type", "target_id"], name: "index_dictionaries_on_target_type_and_target_id"
  end

  create_table "dictionary_elements", force: :cascade do |t|
    t.string   "element_type"
    t.integer  "element_id"
    t.integer  "dictionary_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["dictionary_id"], name: "index_dictionary_elements_on_dictionary_id"
    t.index ["element_type", "element_id"], name: "index_dictionary_elements_on_element_type_and_element_id"
  end

  create_table "handlers", force: :cascade do |t|
    t.string   "short_name"
    t.string   "repo_path"
    t.string   "local_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meta_prints", force: :cascade do |t|
    t.string   "last_ref"
    t.string   "creator"
    t.string   "producer"
    t.integer  "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_meta_prints_on_bank_id"
    t.index ["creator", "producer"], name: "index_meta_prints_on_creator_and_producer", unique: true
  end

  create_table "sequences", force: :cascade do |t|
    t.integer  "tax_id"
    t.integer  "year",       default: 0
    t.integer  "month",      default: 0
    t.integer  "week",       default: 0
    t.integer  "day",        default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["tax_id", "year", "month", "week", "day"], name: "index_sequences_on_tax_id_and_year_and_month_and_week_and_day", unique: true
    t.index ["tax_id"], name: "index_sequences_on_tax_id"
  end

  create_table "societies", force: :cascade do |t|
    t.string   "name"
    t.string   "rut"
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "rut"], name: "index_societies_on_name_and_rut", unique: true
    t.index ["parent_id"], name: "index_societies_on_parent_id"
  end

  create_table "statement_statuses", force: :cascade do |t|
    t.integer  "code"
    t.integer  "progress"
    t.string   "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statements", force: :cascade do |t|
    t.string   "file_name"
    t.string   "path"
    t.integer  "sequence_id"
    t.integer  "bank_id"
    t.integer  "handler_id"
    t.integer  "client_id"
    t.date     "d_filed"
    t.date     "d_open"
    t.date     "d_close"
    t.datetime "d_read"
    t.integer  "status_id"
    t.string   "file_hash"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["bank_id"], name: "index_statements_on_bank_id"
    t.index ["client_id"], name: "index_statements_on_client_id"
    t.index ["file_hash"], name: "index_statements_on_file_hash", unique: true
    t.index ["handler_id"], name: "index_statements_on_handler_id"
    t.index ["sequence_id"], name: "index_statements_on_sequence_id"
    t.index ["status_id"], name: "index_statements_on_status_id"
  end

  create_table "taxes", force: :cascade do |t|
    t.integer  "bank_id"
    t.integer  "society_id"
    t.integer  "quantity"
    t.string   "periodicity"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["bank_id"], name: "index_taxes_on_bank_id"
    t.index ["society_id", "bank_id"], name: "index_taxes_on_society_id_and_bank_id", unique: true
    t.index ["society_id"], name: "index_taxes_on_society_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "role_type"
    t.integer  "role_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_type", "role_id"], name: "index_users_on_role_type_and_role_id"
  end

end
