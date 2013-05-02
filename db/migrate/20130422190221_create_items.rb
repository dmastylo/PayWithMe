class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.integer :event_id
      t.integer :amount_cents
      t.boolean :allow_quantity
      t.integer :quantity_min
      t.integer :quantity_max

      t.timestamps
    end
  end
end
