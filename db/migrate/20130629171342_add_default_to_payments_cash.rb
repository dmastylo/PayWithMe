class AddDefaultToPaymentsCash < ActiveRecord::Migration
  def change
    change_column :payments, :cash, :boolean, default: false
  end
end
