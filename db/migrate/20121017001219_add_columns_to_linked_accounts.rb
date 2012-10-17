class AddColumnsToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :provider, :string
    add_column :linked_accounts, :uid, :string
    add_column :linked_accounts, :token, :string
  end
end
