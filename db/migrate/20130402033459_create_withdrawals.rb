class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.integer :linked_account_id
      t.integer :amount_cents
      t.string :status

      t.timestamps
    end
  end
end
