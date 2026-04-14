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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_100000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "categories", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.decimal "monthly_budget_limit", precision: 10, scale: 2
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.decimal "current_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.text "description"
    t.string "goal_type", null: false
    t.string "status", default: "active", null: false
    t.decimal "target_amount", precision: 10, scale: 2, null: false
    t.date "target_date", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_goals_on_category_id"
    t.index ["user_id", "goal_type"], name: "index_goals_on_user_id_and_goal_type"
    t.index ["user_id", "status"], name: "index_goals_on_user_id_and_status"
    t.index ["user_id", "target_date"], name: "index_goals_on_user_id_and_target_date"
    t.index ["user_id"], name: "index_goals_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.text "description"
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["date"], name: "index_transactions_on_date"
    t.index ["description"], name: "index_transactions_on_description_trgm", opclass: :gin_trgm_ops, where: "(description IS NOT NULL)", using: :gin
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id", "category_id", "date"], name: "index_transactions_on_user_category_and_date"
    t.index ["user_id", "date"], name: "index_transactions_on_user_id_and_date"
    t.index ["user_id", "transaction_type", "date"], name: "index_transactions_on_user_type_and_date"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "users"
  add_foreign_key "goals", "categories"
  add_foreign_key "goals", "users"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
end
