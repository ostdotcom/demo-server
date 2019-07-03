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

ActiveRecord::Schema.define(version: 2019_07_03_055749) do

  create_table "api_endpoints", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "endpoint", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "uk_1", unique: true
  end

  create_table "token_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "username", null: false
    t.text "password", null: false
    t.text "user_pin_salt", null: false
    t.binary "encryption_salt", null: false
    t.string "cookie_salt", null: false
    t.integer "token_id", null: false
    t.integer "ost_token_id", null: false
    t.string "uuid"
    t.string "token_holder_address"
    t.string "device_manager_address"
    t.string "recovery_address"
    t.string "ost_user_status"
    t.integer "ost_activation_ts"
    t.integer "first_transaction_ts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token_id", "username"], name: "uk_1", unique: true
    t.index ["uuid"], name: "uk_2", unique: true
  end

  create_table "tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ost_token_id", null: false
    t.integer "api_endpoint_id", null: false
    t.string "name", null: false
    t.string "symbol", null: false
    t.integer "decimal", limit: 1, null: false
    t.decimal "conversion_factor", precision: 15, scale: 6, null: false
    t.string "url_id", null: false
    t.text "api_key", null: false
    t.text "api_secret", null: false
    t.text "webhook_secret"
    t.binary "encryption_salt", null: false
    t.string "pc_token_holder_uuid", null: false
    t.integer "chain_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ost_token_id", "api_endpoint_id"], name: "uk_2", unique: true
    t.index ["url_id"], name: "uk_1", unique: true
  end

end
