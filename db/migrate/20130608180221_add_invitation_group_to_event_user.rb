class AddInvitationGroupToEventUser < ActiveRecord::Migration
  def change
    add_column :event_users, :invitation_group, :integer, default: 0
  end
end
