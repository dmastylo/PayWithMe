module NewsItemHelper
  def news_item_image_path(news_item, size=:thumb)
    if news_item.event?
      event_image_path(news_item.event, size)
    elsif news_item.group?
      group_image_path(news_item.group, size)
    end
  end

  def news_item_image_tag(news_item, size=:thumb)
    if news_item.event?
      event_image_tag(news_item.event, size)
    elsif news_item.group?
      group_image_tag(news_item.group, size)
    end
  end
end