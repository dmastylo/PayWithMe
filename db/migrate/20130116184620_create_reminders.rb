class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.integer :event_id
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
