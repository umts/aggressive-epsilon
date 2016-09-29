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

ActiveRecord::Schema.define(version: 20160824171959) do

  create_table "damage_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "uuid",       limit: 255
    t.integer  "creator_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "damages", force: :cascade do |t|
    t.string   "uuid",                           limit: 255
    t.string   "damage_issued_reservation_uuid", limit: 255
    t.string   "damage_fixed_reservation_uuid",  limit: 255
    t.integer  "damage_type_id",                 limit: 4
    t.integer  "creator_id",                     limit: 4
    t.integer  "item_id",                        limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "item_types", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "allowed_keys", limit: 255
    t.string   "uuid",         limit: 255
    t.integer  "creator_id",   limit: 4
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "item_type_id", limit: 4
    t.string   "data",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "reservable"
    t.string   "uuid",         limit: 255
  end

  create_table "permissions", force: :cascade do |t|
    t.boolean  "write",                  default: false
    t.integer  "item_type_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "service_id",   limit: 4
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.integer  "item_id",        limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "creator_id",     limit: 4
    t.string   "uuid",           limit: 255
  end

  create_table "services", force: :cascade do |t|
    t.string   "api_key",    limit: 255
    t.string   "name",       limit: 255
    t.string   "url",        limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
