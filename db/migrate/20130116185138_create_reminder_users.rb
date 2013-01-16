class CreateReminderUsers < ActiveRecord::Migration
  def change
    create_table :reminder_users do |t|
      t.integer :reminder_id
      t.integer :user_id
      t.boolean :sent

      t.timestamps
    end
  end
end
