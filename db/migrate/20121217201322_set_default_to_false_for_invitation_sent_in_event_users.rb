class SetDefaultToFalseForInvitationSentInEventUsers < ActiveRecord::Migration
  def change
    change_column_default :event_users, :invitation_sent, :bool, false
  end
end
