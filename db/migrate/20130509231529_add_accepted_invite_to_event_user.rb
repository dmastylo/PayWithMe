class AddAcceptedInviteToEventUser < ActiveRecord::Migration
  def change
    add_column :event_users, :accepted_invite, :boolean
  end
end
