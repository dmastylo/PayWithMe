class ChangeNotificationTypeToIntegerInNotifications < ActiveRecord::Migration
  def change
    change_column :notifications, :notification_type, :int
  end
end
