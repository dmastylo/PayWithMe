class ChangeEventPaymentMethodColumnTypes < ActiveRecord::Migration
  def change
    change_column :event_payment_methods, :event_id, :integer
    change_column :event_payment_methods, :payment_method, :integer
  end
end
