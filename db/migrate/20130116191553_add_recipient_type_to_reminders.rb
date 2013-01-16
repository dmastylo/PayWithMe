class AddRecipientTypeToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :recipient_type, :integer
  end
end
