class AddDefaultValueToSplitAndDealInRestuarantContactsTable < ActiveRecord::Migration
	def change
		change_column :restaurant_contacts, :split, :boolean, :default => true
		change_column :restaurant_contacts, :deal, :boolean, :default => true
	end
end
