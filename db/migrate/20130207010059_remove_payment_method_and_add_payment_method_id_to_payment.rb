class RemovePaymentMethodAndAddPaymentMethodIdToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :payment_method_id, :integer
    remove_column :payments, :payment_method
  end

  def down
    remove_column :payments, :payment_method_id
    add_column :payments, :payment_method, :integer
  end
end
