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

ActiveRecord::Schema.define(version: 20171005195144) do

  create_table "banks", force: :cascade do |t|
    t.string   "name"
    t.string   "folder_name"
    t.string   "code_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["code_name"], name: "index_banks_on_code_name", unique: true
    t.index ["folder_name"], name: "index_banks_on_folder_name", unique: true
  end

  create_table "checkmovs", force: :cascade do |t|
    t.string   "path"
    t.integer  "society_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["society_id"], name: "index_checkmovs_on_society_id"
  end

  create_table "handlers", force: :cascade do |t|
    t.string   "short_name"
    t.string   "repo_path"
    t.string   "local_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["short_name"], name: "index_handlers_on_short_name", unique: true
  end

  create_table "sequences", force: :cascade do |t|
    t.integer  "tax_id"
    t.date     "date"
    t.integer  "quantity"
    t.integer  "optional"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_id", "date"], name: "index_sequences_on_tax_id_and_date", unique: true
    t.index ["tax_id"], name: "index_sequences_on_tax_id"
  end

  create_table "societies", force: :cascade do |t|
    t.string   "name"
    t.string   "rut"
    t.integer  "parent_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "active",     default: true
    t.index ["name", "parent_id"], name: "index_societies_on_name_and_parent_id", unique: true
    t.index ["parent_id"], name: "index_societies_on_parent_id"
  end

  create_table "source_paths", force: :cascade do |t|
    t.string   "path"
    t.integer  "sourceable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "sourceable_type"
    t.string   "key"
    t.index ["path"], name: "index_source_paths_on_path", unique: true
    t.index ["sourceable_id"], name: "index_source_paths_on_sourceable_id"
  end

  create_table "statement_statuses", force: :cascade do |t|
    t.integer  "code"
    t.integer  "progress"
    t.string   "message"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "statements", force: :cascade do |t|
    t.string   "file_name"
    t.string   "path"
    t.integer  "sequence_id"
    t.integer  "handler_id"
    t.date     "d_filed"
    t.integer  "status_id"
    t.string   "file_hash"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["file_hash"], name: "index_statements_on_file_hash", unique: true
    t.index ["handler_id"], name: "index_statements_on_handler_id"
    t.index ["sequence_id"], name: "index_statements_on_sequence_id"
    t.index ["status_id"], name: "index_statements_on_status_id"
  end

  create_table "synonyms", force: :cascade do |t|
    t.string   "listable_type"
    t.integer  "listable_id"
    t.string   "label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["listable_type", "label"], name: "index_synonyms_on_listable_type_and_label", unique: true
    t.index ["listable_type", "listable_id"], name: "index_synonyms_on_listable_type_and_listable_id"
  end

  create_table "taxes", force: :cascade do |t|
    t.integer  "bank_id"
    t.integer  "society_id"
    t.integer  "quantity",    default: 0
    t.integer  "optional",    default: 0
    t.string   "periodicity"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "active",      default: true
    t.index ["bank_id"], name: "index_taxes_on_bank_id"
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
