class CreateRestrauntContacts < ActiveRecord::Migration
  def change
    create_table :restraunt_contacts do |t|
      t.string :email
      t.boolean :split
      t.boolean :deal
      t.string :comment
      t.string :name
      t.string :restaurant_name

      t.timestamps
    end
  end
end
