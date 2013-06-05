class AddAmountsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :total_cents, :int
    add_column :events, :split_cents, :int
    remove_column :events, :amount_cents
  end
end
