class AddProfileImageOptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_image_option, :string
  end
end
