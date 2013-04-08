class AddBalanceCentsToLinkedAccount < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :balance_cents, :integer
  end
end
