class ShuffleAmountColumnsOnPayments < ActiveRecord::Migration
  def change
    add_column :payments, :processor_fee_amount_cents, :integer
    add_column :payments, :our_fee_amount_cents, :integer
  end
end