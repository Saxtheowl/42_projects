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

ActiveRecord::Schema.define(version: 20160101000003) do

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.string   "title",        null: false
    t.text     "content",      null: false
    t.integer  "edited_by_id"
    t.datetime "edited_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "posts", ["edited_by_id"], name: "index_posts_on_edited_by_id"
  add_index "posts", ["title"], name: "index_posts_on_title", unique: true
  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "name",                            null: false
    t.string   "email",                           null: false
    t.string   "password_digest",                 null: false
    t.boolean  "admin",           default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["name"], name: "index_users_on_name", unique: true

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "post_id",    null: false
    t.integer  "value",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "votes", ["post_id"], name: "index_votes_on_post_id"
  add_index "votes", ["user_id", "post_id"], name: "index_votes_on_user_id_and_post_id", unique: true
  add_index "votes", ["user_id"], name: "index_votes_on_user_id"

end
