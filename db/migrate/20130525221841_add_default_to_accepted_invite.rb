class AddDefaultToAcceptedInvite < ActiveRecord::Migration
  def change
    change_column :event_users, :accepted_invite, :boolean, default: false
  end
end
