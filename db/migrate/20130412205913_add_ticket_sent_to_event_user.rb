class AddTicketSentToEventUser < ActiveRecord::Migration
  def change
    add_column :event_users, :ticket_sent, :boolean, :default => false
  end
end
