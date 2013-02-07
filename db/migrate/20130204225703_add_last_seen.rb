class AddLastSeen < ActiveRecord::Migration
  def change
    add_column :event_users, :last_seen, :datetime
  end
end
