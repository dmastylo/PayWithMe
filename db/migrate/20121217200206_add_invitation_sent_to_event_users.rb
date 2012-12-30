class AddInvitationSentToEventUsers < ActiveRecord::Migration
  def change
<<<<<<< HEAD
    add_column :event_users, :invitation_sent, :boolean
=======
    add_column :event_users, :invitation_sent, :boolean, default: false
>>>>>>> master
  end
end
