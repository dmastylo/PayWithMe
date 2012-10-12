class AddForeignIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :foreign_id, :int
  end
end
