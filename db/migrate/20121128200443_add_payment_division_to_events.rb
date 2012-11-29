class AddPaymentDivisionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :payment_division, :string
  end
end
