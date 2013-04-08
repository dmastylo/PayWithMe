class AddTransactionIdToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :transaction_id, :string
  end
end
