class RemoveProfileImageOptionFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :profile_image_option
    add_column :users, :profile_image_url, :string
  end

  def down
    add_column :users, :profile_image_option, :string
    remove_column :users, :profile_image_url
  end
end
