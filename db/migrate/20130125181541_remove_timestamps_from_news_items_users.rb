class RemoveTimestampsFromNewsItemsUsers < ActiveRecord::Migration
  def up
    remove_column :news_items_users, :created_at
    remove_column :news_items_users, :updated_at
  end

  def down
    add_column :news_items_users, :updated_at, :datetime
    add_column :news_items_users, :created_at, :datetime
  end
end
