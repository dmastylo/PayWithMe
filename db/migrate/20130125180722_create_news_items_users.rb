class CreateNewsItemsUsers < ActiveRecord::Migration
  def change
    create_table :news_items_users do |t|
      t.integer :user_id
      t.integer :news_item_id

      t.timestamps
    end
  end
end
