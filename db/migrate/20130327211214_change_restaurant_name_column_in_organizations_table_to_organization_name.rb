class ChangeRestaurantNameColumnInOrganizationsTableToOrganizationName < ActiveRecord::Migration
  def up
  	rename_column :organizations, :restaurant_name, :organization_name
  end

  def down
  	rename_column :organizations, :organization_name, :restaurant_name
  end
end
