class RenameRestrauntToRestaurant < ActiveRecord::Migration
  def change
  	rename_table :restraunt_contacts, :restaurant_contacts
  end
end
