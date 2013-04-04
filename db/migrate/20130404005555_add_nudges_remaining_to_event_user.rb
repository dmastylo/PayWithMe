class AddNudgesRemainingToEventUser < ActiveRecord::Migration
  def change
    add_column :event_users, :nudges_remaining, :integer, default: 0
  end
end
