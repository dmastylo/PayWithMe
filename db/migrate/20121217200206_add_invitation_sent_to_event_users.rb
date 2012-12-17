class AddInvitationSentToEventUsers < ActiveRecord::Migration
  def change
    add_column :event_users, :invitation_sent, :bool
  end
end
