class AddInvitationSentToGroupUsers < ActiveRecord::Migration
  def change
    add_column :group_users, :invitation_sent, :boolean, default: false
  end
end
