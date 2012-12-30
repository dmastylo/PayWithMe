class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :type
      t.string :body
      t.string :path

      t.timestamps
    end
  end
end
