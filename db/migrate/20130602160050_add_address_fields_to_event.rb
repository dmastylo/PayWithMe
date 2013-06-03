class AddAddressFieldsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :location_title, :string
    add_column :events, :location_address, :string
  end
end
