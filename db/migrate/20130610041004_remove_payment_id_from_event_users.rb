class RemovePaymentIdFromEventUsers < ActiveRecord::Migration
  def change
    remove_column :event_users, :payment_id, :integer
  end
end
