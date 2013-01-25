class RenameEventPaymentMethodsToPaymentMethods < ActiveRecord::Migration
  def up
    rename_table :event_payment_methods, :payment_methods
  end

  def down
    rename_table :payment_methods, :event_payment_methdos
  end
end
