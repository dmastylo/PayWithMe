class UpdateTablesToFitNewRelationships < ActiveRecord::Migration
  def up
    drop_table :event_users
    remove_column :payments, :event_user_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
