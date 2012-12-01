class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.references :event
      t.references :user

      t.timestamps
    end
    add_index :messages, :event_id
    add_index :messages, :user_id
  end
end
