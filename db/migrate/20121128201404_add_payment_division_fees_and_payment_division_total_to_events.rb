class AddPaymentDivisionFeesAndPaymentDivisionTotalToEvents < ActiveRecord::Migration
  def change
    add_column :events, :payment_division_fees, :string
    add_column :events, :payment_division_total, :string
  end
end
