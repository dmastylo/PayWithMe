class RemoveTitleFromNewsItems < ActiveRecord::Migration
  def up
    remove_column :news_items, :title
  end

  def down
    add_column :news_items, :title, :string
  end
end
