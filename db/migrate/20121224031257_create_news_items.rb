class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :title
      t.string :body
      t.string :path
      t.boolean :read
      t.integer :type
      t.references :user

      t.timestamps
    end
    add_index :news_items, :user_id
  end
end
