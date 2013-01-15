class AddPaymentIdToEventUser < ActiveRecord::Migration
  def change
    add_column :event_users, :payment_id, :integer
  end
end
