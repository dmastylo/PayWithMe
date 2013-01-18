class AddTransactionIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :transaction_id, :string
  end
end
