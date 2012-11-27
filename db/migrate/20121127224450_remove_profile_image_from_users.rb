class RemoveProfileImageFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :profile_image
  end

  def down
    add_column :users, :profile_image, :string
  end
end
