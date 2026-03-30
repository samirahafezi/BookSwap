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

ActiveRecord::Schema[8.1].define(version: 2026_03_30_000002) do
  create_table "books", force: :cascade do |t|
    t.string "author"
    t.boolean "borrowable"
    t.string "condition"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "genre"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", default: 1, null: false
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "borrows", force: :cascade do |t|
    t.integer "book_id", null: false
    t.datetime "borrowed_at"
    t.integer "borrower_id", null: false
    t.datetime "created_at", null: false
    t.datetime "due_at"
    t.datetime "due_soon_reminder_sent_at"
    t.datetime "overdue_reminder_sent_at"
    t.datetime "returned_at"
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_borrows_on_book_id"
    t.index ["borrower_id"], name: "index_borrows_on_borrower_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "borrow_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "ratee_id", null: false
    t.integer "rater_id", null: false
    t.integer "stars", null: false
    t.datetime "updated_at", null: false
    t.index ["borrow_id"], name: "index_ratings_on_borrow_id", unique: true
    t.index ["ratee_id"], name: "index_ratings_on_ratee_id"
    t.index ["rater_id"], name: "index_ratings_on_rater_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.datetime "last_login"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "phone_number"
    t.integer "total_books"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "books", "users"
  add_foreign_key "borrows", "books"
  add_foreign_key "borrows", "users", column: "borrower_id"
  add_foreign_key "ratings", "borrows"
  add_foreign_key "ratings", "users", column: "ratee_id"
  add_foreign_key "ratings", "users", column: "rater_id"
  add_foreign_key "sessions", "users"
end
