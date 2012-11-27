class AddProfileImageAttachmentToUsers < ActiveRecord::Migration
  def up
    add_attachment :users, :profile_image
  end

  def down
    add_attachment :users, :avatar
  end
end
