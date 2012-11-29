class RemoveDivisionColumnsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :division
    remove_column :events, :payment_division
    remove_column :events, :payment_division_fees
    remove_column :events, :payment_division_total
  end
end
