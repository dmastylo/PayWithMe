class RemoveReadBooleanNewsItem < ActiveRecord::Migration
    def change
        remove_column :news_items, :read
    end
end
