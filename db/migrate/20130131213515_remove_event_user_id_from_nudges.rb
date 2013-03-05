class RemoveEventUserIdFromNudges < ActiveRecord::Migration
  def up
    remove_column :nudges, :event_user_id
  end

  def down
    add_column :nudges, :event_user_id, :integer
  end
end
