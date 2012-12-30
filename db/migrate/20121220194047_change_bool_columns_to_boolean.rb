class ChangeBoolColumnsToBoolean < ActiveRecord::Migration
  def change
    change_column :group_users, :invitation_sent, :boolean
    change_column :event_users, :invitation_sent, :boolean
  end
end