class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.int :user_id
      t.string :type
      t.string :body

      t.timestamps
    end
  end
end
