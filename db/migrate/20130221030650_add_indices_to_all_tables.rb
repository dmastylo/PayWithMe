class AddIndicesToAllTables < ActiveRecord::Migration
  def change
    add_index "payments", ["event_user_id"], name: "index_payments_on_event_user_id"
    add_index "event_users", ["event_id", "user_id"], name: "index_event_users_on_event_id_and_user_id"
    add_index "event_users", ["event_id"], name: "index_event_users_on_event_id"
    add_index "payment_methods", ["name"], name: "index_payment_methods_on_name"
  end
end
