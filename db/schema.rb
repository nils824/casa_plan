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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_120000) do
  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event", null: false
    t.integer "stay_id", null: false
    t.string "summary", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["stay_id"], name: "index_activities_on_stay_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "houses", force: :cascade do |t|
    t.integer "beds", null: false
    t.datetime "created_at", null: false
    t.string "invitation_code"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stays", force: :cascade do |t|
    t.date "arrival_on", null: false
    t.datetime "created_at", null: false
    t.datetime "decided_at"
    t.integer "decided_by_id"
    t.date "departure_on", null: false
    t.integer "guests_count", null: false
    t.integer "house_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.text "note"
    t.text "rejection_reason"
    t.string "status", default: "requested", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["decided_by_id"], name: "index_stays_on_decided_by_id"
    t.index ["house_id", "status", "arrival_on"], name: "index_stays_on_house_id_and_status_and_arrival_on"
    t.index ["house_id"], name: "index_stays_on_house_id"
    t.index ["user_id"], name: "index_stays_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "email_confirmation_token"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["email_confirmation_token"], name: "index_users_on_email_confirmation_token", unique: true
  end

  add_foreign_key "activities", "stays"
  add_foreign_key "activities", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "stays", "houses"
  add_foreign_key "stays", "users"
  add_foreign_key "stays", "users", column: "decided_by_id"
end
