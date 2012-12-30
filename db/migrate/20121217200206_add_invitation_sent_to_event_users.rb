class AddInvitationSentToEventUsers < ActiveRecord::Migration
  def change
    add_column :event_users, :invitation_sent, :boolean, default: false
  end
end
