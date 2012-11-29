class RemovePaymentDivisionStructureFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :payment_division_structure
  end

  def down
    add_column :events, :payment_division_structure, :string
  end
end
