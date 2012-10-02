class RemoveFieldsFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :info
    remove_column :users, :credentials
    remove_column :users, :extra
  end
end
