class CreateEventSettings < ActiveRecord::Migration
  def change
    create_table :event_settings do |t|
      t.integer :event_id

      t.timestamps
    end
  end
end
