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

ActiveRecord::Schema.define(:version => 20130707203507) do

  create_table "affiliates", :force => true do |t|
    t.string   "name"
    t.string   "school"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "affiliate_type"
  end

  create_table "contact_forms", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "user_id"
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

  create_table "event_users", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.integer  "amount_cents",     :default => 0
    t.datetime "due_at"
    t.datetime "paid_at"
    t.boolean  "invitation_sent",  :default => false
    t.integer  "payment_id"
    t.boolean  "visited_event",    :default => false
    t.datetime "last_seen"
    t.boolean  "paid_with_cash",   :default => true
    t.integer  "paid_total_cents", :default => 0
    t.integer  "status",           :default => 0
    t.integer  "nudges_remaining", :default => 0
    t.boolean  "accepted_invite",  :default => false
  end

  add_index "event_users", ["event_id", "user_id"], :name => "index_event_users_on_event_id_and_user_id"
  add_index "event_users", ["event_id"], :name => "index_event_users_on_event_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "due_at"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "division_type"
    t.integer  "total_amount_cents"
    t.integer  "split_amount_cents"
    t.integer  "organizer_id"
    t.integer  "privacy_type"
    t.string   "slug"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_url"
    t.string   "guest_token"
    t.integer  "fundraiser_goal_cents"
    t.integer  "minimum_donation_cents"
    t.datetime "last_auto_email_sent"
    t.datetime "last_daily_email_sent"
  end

  add_index "events", ["slug"], :name => "index_events_on_slug"

  create_table "events_payment_methods", :force => true do |t|
    t.integer "event_id"
    t.integer "payment_method_id"
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "group_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "invitation_sent", :default => false
  end

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "slug"
    t.integer  "organizer_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_url"
  end

  add_index "groups", ["slug"], :name => "index_groups_on_slug"

  create_table "invitation_types", :force => true do |t|
    t.integer  "invitation_type"
    t.integer  "event_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "item_users", :force => true do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.integer  "event_user_id"
    t.integer  "payment_id"
    t.integer  "event_id"
    t.integer  "quantity"
    t.integer  "total_amount_cents"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "title"
    t.integer  "event_id"
    t.integer  "amount_cents"
    t.boolean  "allow_quantity"
    t.integer  "quantity_min"
    t.integer  "quantity_max"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "linked_accounts", :force => true do |t|
    t.string   "provider"
    t.string   "token"
    t.integer  "user_id"
    t.string   "uid"
    t.string   "token_secret"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "email"
    t.integer  "balance_cents"
    t.datetime "balanced_at"
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
    t.boolean  "read",         :default => false
  end

  add_index "news_items", ["user_id"], :name => "index_news_items_on_user_id"

  create_table "news_items_users", :force => true do |t|
    t.integer "user_id"
    t.integer "news_item_id"
  end

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

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "nudges", :force => true do |t|
    t.integer  "nudgee_id"
    t.integer  "nudger_id"
    t.integer  "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "sent_at"
    t.integer  "rating"
  end

  create_table "organizations", :force => true do |t|
    t.string   "email"
    t.boolean  "split",      :default => true
    t.boolean  "deal",       :default => true
    t.string   "comment"
    t.string   "name"
    t.string   "contact"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "type"
  end

  create_table "payment_methods", :force => true do |t|
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "static_fee_cents"
    t.decimal  "percent_fee",         :precision => 8, :scale => 4
    t.integer  "minimum_fee_cents"
    t.integer  "fee_threshold_cents"
    t.string   "name"
  end

  add_index "payment_methods", ["name"], :name => "index_payment_methods_on_name"

  create_table "payments", :force => true do |t|
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.datetime "requested_at"
    t.datetime "paid_at"
    t.datetime "due_at"
    t.integer  "payer_id"
    t.integer  "payee_id"
    t.integer  "event_id"
    t.integer  "amount_cents"
    t.integer  "event_user_id"
    t.string   "transaction_id"
    t.integer  "processor_fee_amount_cents"
    t.integer  "our_fee_amount_cents"
    t.integer  "payment_method_id"
    t.string   "status",                     :default => "new"
    t.integer  "status_type"
  end

  add_index "payments", ["event_user_id"], :name => "index_payments_on_event_user_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "published"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.string   "slug"
    t.integer  "creator_id"
    t.datetime "completed_at"
    t.boolean  "admin"
    t.boolean  "send_emails",                :default => true
    t.boolean  "using_cash",                 :default => false
    t.integer  "referrer_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug"

  create_table "vanity_conversions", :force => true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], :name => "by_experiment_id_and_alternative"

  create_table "vanity_experiments", :force => true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
    t.boolean  "enabled"
  end

  add_index "vanity_experiments", ["experiment_id"], :name => "index_vanity_experiments_on_experiment_id"

  create_table "vanity_metric_counts", :force => true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.string  "metric"
    t.integer "count"
  end

  add_index "vanity_metric_counts", ["vanity_experiment_id", "alternative", "metric"], :name => "by_experiment_id_and_alternative_and_metric"

  create_table "vanity_metric_values", :force => true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], :name => "index_vanity_metric_values_on_vanity_metric_id"

  create_table "vanity_metrics", :force => true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], :name => "index_vanity_metrics_on_metric_id"

  create_table "vanity_participants", :force => true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], :name => "by_experiment_id_and_converted"
  add_index "vanity_participants", ["experiment_id", "identity"], :name => "by_experiment_id_and_identity"
  add_index "vanity_participants", ["experiment_id", "seen"], :name => "by_experiment_id_and_seen"
  add_index "vanity_participants", ["experiment_id", "shown"], :name => "by_experiment_id_and_shown"
  add_index "vanity_participants", ["experiment_id"], :name => "index_vanity_participants_on_experiment_id"

  create_table "withdrawals", :force => true do |t|
    t.integer  "linked_account_id"
    t.integer  "amount_cents"
    t.string   "status",            :default => "new"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "transaction_id"
  end

end
