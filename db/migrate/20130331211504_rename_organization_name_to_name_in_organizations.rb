class RenameOrganizationNameToNameInOrganizations < ActiveRecord::Migration
  def change
  	rename_column :organizations, :organization_name, :contact
  end
end
