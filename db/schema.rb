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

ActiveRecord::Schema.define(:version => 20130117190945) do

  create_table "contact_forms", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_groups", :force => true do |t|
    t.integer  "event_id"
    t.integer  "group_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "event_settings", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "event_users", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "amount_cents",    :default => 0
    t.datetime "due_at"
    t.datetime "paid_at"
    t.boolean  "invitation_sent", :default => false
    t.integer  "payment_id"
  end

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "due_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "start_at"
    t.integer  "division_type"
    t.integer  "fee_type"
    t.integer  "total_amount_cents"
    t.integer  "split_amount_cents"
    t.integer  "organizer_id"
    t.integer  "privacy_type"
  end

  create_table "group_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "admin",           :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "invitation_sent", :default => false
  end

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "linked_accounts", :force => true do |t|
    t.string   "provider"
    t.string   "token"
    t.integer  "user_id"
    t.string   "uid"
    t.string   "token_secret"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
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

  create_table "news_items", :force => true do |t|
    t.integer  "news_type"
    t.integer  "user_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "foreign_id"
    t.integer  "foreign_type"
    t.integer  "subject_id"
    t.boolean  "read",         :default => false
  end

  add_index "news_items", ["user_id"], :name => "index_news_items_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_type", :limit => 255
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.boolean  "read",                             :default => false
    t.integer  "foreign_id"
    t.integer  "foreign_type"
    t.integer  "subject_id"
  end

  create_table "payments", :force => true do |t|
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "requested_at"
    t.datetime "paid_at"
    t.datetime "due_at"
    t.integer  "payer_id"
    t.integer  "payee_id"
    t.integer  "event_id"
    t.integer  "amount_cents"
    t.integer  "event_user_id"
  end

  create_table "reminder_users", :force => true do |t|
    t.integer  "reminder_id"
    t.integer  "user_id"
    t.boolean  "sent",        :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "reminders", :force => true do |t|
    t.integer  "event_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "recipient_type"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                      :default => "",                           :null => false
    t.string   "encrypted_password",         :default => "",                           :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "name"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
    t.string   "profile_image_url"
    t.boolean  "stub",                       :default => false
    t.string   "guest_token"
    t.boolean  "using_oauth"
    t.datetime "last_seen"
    t.string   "time_zone",                  :default => "Eastern Time (US & Canada)"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
