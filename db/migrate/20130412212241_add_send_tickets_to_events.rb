class AddSendTicketsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :send_tickets, :boolean, :default => false
  end
end
