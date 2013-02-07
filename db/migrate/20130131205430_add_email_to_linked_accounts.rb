class AddEmailToLinkedAccounts < ActiveRecord::Migration
  def change
    add_column :linked_accounts, :email, :string
  end
end
