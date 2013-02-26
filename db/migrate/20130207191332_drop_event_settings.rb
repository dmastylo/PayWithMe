class DropEventSettings < ActiveRecord::Migration
  def up
    drop_table :event_settings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
