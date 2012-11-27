class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.float :amount
      t.date :due_date

      t.timestamps
    end
  end
end
