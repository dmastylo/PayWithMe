class AddPaymentMethodsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :payment_methods, :string
  end
end
