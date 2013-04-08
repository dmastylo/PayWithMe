class AddBalancedAtToLinkedAccount < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :balanced_at, :datetime
  end
end
