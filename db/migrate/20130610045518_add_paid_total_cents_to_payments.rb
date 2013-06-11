class AddPaidTotalCentsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :paid_amount_cents, :integer
  end
end
