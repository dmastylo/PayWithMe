class CreatePaymentsProcessors < ActiveRecord::Migration
  def change
    create_table :payments_processors do |t|
      t.integer :processor_id
      t.integer :payment_id

      t.timestamps
    end
  end
end
