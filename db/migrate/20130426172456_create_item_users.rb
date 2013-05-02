class CreateItemUsers < ActiveRecord::Migration
  def change
    create_table :item_users do |t|
      t.integer :item_id
      t.integer :user_id
      t.integer :event_user_id
      t.integer :payment_id
      t.integer :event_id
      t.integer :quantity
      t.integer :total_amount_cents

      t.timestamps
    end
  end
end
