class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|
      t.string :provider
      t.string :token
      t.integer :user_id
      t.string :uid
      t.string :token_secret

      t.timestamps
    end
  end
end
