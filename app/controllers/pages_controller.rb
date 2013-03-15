class PagesController < ApplicationController
  after_filter :read_news_items, only: [:index]

  def index
    @upcoming_events = current_user.limited_upcoming_events if user_signed_in?
    @news_items = current_user.news_items.where("foreign_type <> #{NewsItem::ForeignType::ORGANIZER}").paginate(page: params[:page], :per_page => 15) if user_signed_in?
  end

private
  def read_news_items
    @news_items.each do |news_item| news_item.read! end if user_signed_in?
  end
end
