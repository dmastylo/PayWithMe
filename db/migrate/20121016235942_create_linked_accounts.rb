class CreateLinkedAccounts < ActiveRecord::Migration
  def change
    create_table :linked_accounts do |t|

      t.timestamps
    end
  end
end
