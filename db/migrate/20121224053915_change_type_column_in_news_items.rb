class ChangeTypeColumnInNewsItems < ActiveRecord::Migration
    def change
        rename_column :news_items, :type, :news_type
    end
end
