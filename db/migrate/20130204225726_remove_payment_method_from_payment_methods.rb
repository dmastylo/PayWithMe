class RemovePaymentMethodFromPaymentMethods < ActiveRecord::Migration
  def up
    remove_column :payment_methods, :payment_method
    remove_column :payment_methods, :event_id
  end

  def down
    add_column :payment_methods, :payment_method, :integer
    add_column :payment_methods, :event_id, :integer
  end
end