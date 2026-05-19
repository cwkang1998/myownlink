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

ActiveRecord::Schema[8.1].define(version: 2026_05_19_073919) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "shorturl_accesses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "geolocation"
    t.bigint "shorturl_id", null: false
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.index ["shorturl_id"], name: "index_shorturl_accesses_on_shorturl_id"
  end

  create_table "shorturls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "target_url"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "shorturl_accesses", "shorturls"
end
