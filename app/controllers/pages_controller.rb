class PagesController < ApplicationController
  after_filter :read_news_items, only: [:index]

  caches_page :index, :team, :faq, :privacy_policy

  def index
    @upcoming_events = current_user.limited_upcoming_events if user_signed_in?
    @news_items = current_user.news_items.paginate(page: params[:page], :per_page => 15) if user_signed_in?
  end

private
  def read_news_items
    @news_items.each do |news_item| news_item.read! end if user_signed_in?
  end
end
