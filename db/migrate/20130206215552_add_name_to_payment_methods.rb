class AddNameToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :name, :string
  end
end
