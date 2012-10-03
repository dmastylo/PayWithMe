class RemoveAuthHashFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :auth_hash
  end
end
