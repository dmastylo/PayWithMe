class RemoveSubjectIdFromNewsItems < ActiveRecord::Migration
  def up
    NewsItem.all.each do |news_item|
      if news_item.subject_id.present?
        news_item.subjects << User.find(news_item.subject_id)
      end
    end

    remove_column :news_items, :subject_id
  end

  def down
    add_column :news_items, :subject_id

    NewsItem.all.each do |news_item|
      if news_item.subjects.count > 0
        news_item.subject_id = news_item.subjects.first.id
      end
    end
  end
end
