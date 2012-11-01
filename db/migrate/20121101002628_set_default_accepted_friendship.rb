class SetDefaultAcceptedFriendship < ActiveRecord::Migration
  def up
    change_column :friendships, :accepted, :int, default: 0
  end

  def down
  end
end
