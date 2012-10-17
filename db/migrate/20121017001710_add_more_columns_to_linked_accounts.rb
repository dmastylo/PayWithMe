class AddMoreColumnsToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :user_id, :int
    add_column :linked_accounts, :token_secret, :string
  end
end
