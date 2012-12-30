class ChangeNotificationTypeToIntegerInNotifications < ActiveRecord::Migration
  def change
    change_column :notifications, :notification_type, :integer
  end
end
