class DropFriendlyIdTable < ActiveRecord::Migration
  def up
  	drop_table :friendly_id_slugs
  end

  def down
  	raise ActiveRecord::IrreversibleMigration
  end
end
