class RemovePaymentMethodsFromEvents < ActiveRecord::Migration
  def change
  	remove_column :events, :payment_methods
  end
end
