# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150808180533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "merchants", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "status",       default: 1
    t.text     "about"
    t.integer  "gender",       default: 0
    t.float    "price"
    t.integer  "review_count"
    t.float    "avg_rating"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "merchants", ["avg_rating"], name: "index_merchants_on_avg_rating", using: :btree
  add_index "merchants", ["email"], name: "index_merchants_on_email", unique: true, using: :btree
  add_index "merchants", ["price"], name: "index_merchants_on_price", using: :btree

  create_table "merchants_specializations", force: :cascade do |t|
    t.integer "merchant_id"
    t.integer "specialization_id"
  end

  add_index "merchants_specializations", ["merchant_id"], name: "index_merchants_specializations_on_merchant_id", using: :btree
  add_index "merchants_specializations", ["specialization_id"], name: "index_merchants_specializations_on_specialization_id", using: :btree

  create_table "openings", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "status",              default: 0
    t.integer  "merchant_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "session_time_in_sec"
  end

  add_index "openings", ["merchant_id"], name: "index_openings_on_merchant_id", using: :btree
  add_index "openings", ["session_time_in_sec"], name: "index_openings_on_session_time_in_sec", using: :btree

  create_table "specializations", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "merchants_specializations", "merchants"
  add_foreign_key "merchants_specializations", "specializations"
  add_foreign_key "openings", "merchants"
end
