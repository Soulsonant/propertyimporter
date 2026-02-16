# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_15_165656) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "create_import_sessions", force: :cascade do |t|
    t.string "status"
    t.jsonb "parsed_data"
    t.integer "dismissed_rows"
    t.string "original_filename"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "create_units", force: :cascade do |t|
    t.string "unit_number"
    t.bigint "property_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_create_units_on_property_id"
  end

  create_table "import_sessions", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.jsonb "parsed_data", default: [], null: false
    t.integer "dismissed_rows", default: [], null: false, array: true
    t.string "original_filename"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_import_sessions_on_status"
  end

  create_table "properties", force: :cascade do |t|
    t.string "name", null: false
    t.string "street_address", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_properties_on_name", unique: true
  end

  create_table "property_infos", force: :cascade do |t|
    t.string "building_name"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "unit_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "unit_number"], name: "index_units_on_property_id_and_unit_number", unique: true
    t.index ["property_id"], name: "index_units_on_property_id"
  end

  add_foreign_key "create_units", "properties"
  add_foreign_key "units", "properties"
end
