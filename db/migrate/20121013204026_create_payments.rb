class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :payee_id
      t.integer :payer_id
      t.float :amount
      t.datetime :paid_at
      t.datetime :desired_at

      t.timestamps
    end
  end
end
