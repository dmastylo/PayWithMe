class AddForeignTypeAndSubjectIdToNewsItems < ActiveRecord::Migration
  def change
    add_column :news_items, :foreign_type, :integer
    add_column :news_items, :subject_id, :integer
  end
end
