class RemoveCreatedAtAndUpdatedAtFromEventUsers < ActiveRecord::Migration
  def up
    remove_column :event_users, :created_at
    remove_column :event_users, :updated_at
  end

  def down
    add_column :event_users, :updated_at, :datetime
    add_column :event_users, :created_at, :datetime
  end
end
