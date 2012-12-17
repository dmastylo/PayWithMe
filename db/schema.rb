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

ActiveRecord::Schema.define(:version => 20121217160251) do

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
    t.integer "event_id"
    t.integer "user_id"
    t.integer "amount_cents", :default => 0
    t.date    "due_date"
    t.date    "paid_date"
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

# Could not dump table "users" because of following StandardError
#   Unknown type 'bool' for column 'using_oauth'

end
