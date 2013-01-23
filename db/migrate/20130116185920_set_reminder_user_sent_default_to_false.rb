class SetReminderUserSentDefaultToFalse < ActiveRecord::Migration
  def up
  	change_column :reminder_users, :sent, :boolean, default: false
  end

  def down
  end
end
