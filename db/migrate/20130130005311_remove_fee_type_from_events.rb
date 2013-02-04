class RemoveFeeTypeFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :fee_type
  end

  def down
    add_column :events, :fee_type, :integer
  end
end
