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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121206203639) do

  create_table "event_settings", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "event_users", :force => true do |t|
    t.integer "event_id"
    t.integer "user_id"
    t.integer "amount_cents", :default => 0
    t.date    "due_date"
    t.date    "paid_date"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "due_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "start_at"
    t.integer  "division_type"
    t.integer  "fee_type"
    t.integer  "total_amount_cents"
    t.integer  "split_amount_cents"
    t.integer  "organizer_id"
  end

  create_table "group_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "admin",      :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "message"
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "messages", ["event_id"], :name => "index_messages_on_event_id"
  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                      :default => "",    :null => false
    t.string   "encrypted_password",         :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.string   "profile_image_url"
    t.boolean  "stub",                       :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
