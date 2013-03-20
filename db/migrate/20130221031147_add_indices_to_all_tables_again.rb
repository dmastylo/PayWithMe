class AddIndicesToAllTablesAgain < ActiveRecord::Migration
  def change
    add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"
  end
end
