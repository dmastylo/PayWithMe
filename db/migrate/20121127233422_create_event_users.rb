class CreateEventUsers < ActiveRecord::Migration
  def change
    create_table :event_users do |t|
      t.integer :event_id
      t.integer :user_id
      t.float :amount
      t.date :due_date
      t.date :paid_date

      t.timestamps
    end
  end
end
