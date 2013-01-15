class AddReadColumnToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :read, :boolean, default: false
  end
end
