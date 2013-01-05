class AddSubjectIdAndRemoveBodyFromNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :subject_id, :integer
    remove_column :notifications, :body
  end
end
