class AddPaymentMethodToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method, :integer
  end
end