class AddAmountsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :total_amount_cents, :int
    add_column :events, :split_amount_cents, :int
    remove_column :events, :amount_cents
  end
end
