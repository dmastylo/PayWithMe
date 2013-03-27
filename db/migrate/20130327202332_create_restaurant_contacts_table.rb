class CreateRestaurantContactsTable < ActiveRecord::Migration
	def change
	  create_table :restaurant_contacts do |t|
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
