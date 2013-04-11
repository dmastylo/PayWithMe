class RenameRestaurantContactsTableToOrganizations < ActiveRecord::Migration
  def self.up
    rename_table :restaurant_contacts, :organizations
  end
  def self.down
    rename_table :organizations, :restaurant_contacts
  end
end
