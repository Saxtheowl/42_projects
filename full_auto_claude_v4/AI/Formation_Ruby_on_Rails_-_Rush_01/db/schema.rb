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

ActiveRecord::Schema.define(version: 2026_02_01_180719) do

  create_table "activity_logs", force: :cascade do |t|
    t.integer "user_id"
    t.string "action"
    t.string "trackable_type"
    t.integer "trackable_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_activity_logs_on_trackable_type_and_trackable_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.integer "company_id"
    t.string "position"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "in_mails", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.string "subject"
    t.text "body"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_in_mails_on_recipient_id"
    t.index ["sender_id"], name: "index_in_mails_on_sender_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "project_id"
    t.string "invoice_type"
    t.text "intro"
    t.decimal "total"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_invoices_on_project_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.string "itemable_type"
    t.integer "itemable_id"
    t.string "description"
    t.decimal "price"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["itemable_type", "itemable_id"], name: "index_line_items_on_itemable_type_and_itemable_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "project_id"
    t.text "intro"
    t.decimal "total"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_orders_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.integer "client_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.integer "project_id"
    t.text "intro"
    t.decimal "total"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_quotes_on_project_id"
  end

  create_table "survey_answers", force: :cascade do |t|
    t.integer "survey_response_id"
    t.integer "survey_question_id"
    t.boolean "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_survey_answers_on_survey_response_id"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer "survey_id"
    t.string "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_questions_on_survey_id"
  end

  create_table "survey_responses", force: :cascade do |t|
    t.integer "survey_id"
    t.string "email"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id"
    t.index ["user_id"], name: "index_survey_responses_on_user_id"
  end

  create_table "surveys", force: :cascade do |t|
    t.string "title"
    t.text "intro"
    t.text "thank_you"
    t.integer "user_id"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_surveys_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "operator"
    t.string "operator_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
