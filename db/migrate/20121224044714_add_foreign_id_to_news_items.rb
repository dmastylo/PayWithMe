class AddForeignIdToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :foreign_id, :integer
  end
end
