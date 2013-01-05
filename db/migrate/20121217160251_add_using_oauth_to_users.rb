class AddUsingOauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :using_oauth, :boolean
  end
end
