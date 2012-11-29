class AddPaymentDivisionStructureToEvents < ActiveRecord::Migration
  def change
    add_column :events, :payment_division_structure, :string
  end
end
