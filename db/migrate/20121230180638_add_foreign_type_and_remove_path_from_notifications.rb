class AddForeignTypeAndRemovePathFromNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :foreign_type, :integer
    remove_column :notifications, :path
  end
end
