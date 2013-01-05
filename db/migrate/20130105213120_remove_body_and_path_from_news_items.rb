class RemoveBodyAndPathFromNewsItems < ActiveRecord::Migration
  def change
  	remove_column :news_items, :body
  	remove_column :news_items, :path
  end
end
