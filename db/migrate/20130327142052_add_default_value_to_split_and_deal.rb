class AddDefaultValueToSplitAndDeal < ActiveRecord::Migration
  def change
  	change_column :restraunt_contacts, :split, :boolean, :default => true
  	change_column :restraunt_contacts, :deal, :boolean, :default => true
  end
end
