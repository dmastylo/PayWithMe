class UpdateEventUserSentColumns < ActiveRecord::Migration
  def change
    rename_column :event_users, :invitation_sent, :sent_invitation_email
    rename_column :event_users, :ticket_sent, :sent_ticket_email
    add_column :event_users, :sent_invitation_notification, :boolean, default: false
    add_column :event_users, :sent_guest_broadcast, :boolean, default: false
  end
end