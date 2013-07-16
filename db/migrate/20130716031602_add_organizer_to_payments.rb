class AddOrganizerToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :organizer, :boolean, default: false
  end
end
