class CreateNudges < ActiveRecord::Migration
  def change
    create_table :nudges do |t|
      t.integer :nudgee_id
      t.integer :nudger_id
      t.integer :event_id
      t.integer :event_user_id

      t.timestamps
    end
  end
end
