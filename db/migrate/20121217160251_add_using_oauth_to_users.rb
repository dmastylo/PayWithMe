class AddUsingOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :using_oauth, :bool
  end
end
