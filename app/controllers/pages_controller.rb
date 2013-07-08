class PagesController < ApplicationController
  after_filter :read_news_items, only: [:index]
  before_filter :authenticate_user!, only: [:contacts_callback]

  # caches_page :index

  def index
    @upcoming_events = current_user.limited_upcoming_events if user_signed_in?
    @news_items = current_user.news_items.paginate(page: params[:page], :per_page => 15) if user_signed_in?
  end

  def contacts_callback
    @contacts = request.env['omnicontacts.contacts']
    @gmail_user = request.env['omnicontacts.user']
    @contacts.delete_if { |contact| contact[:email].blank? }
  end

private
  def read_news_items
    @news_items.each do |news_item| news_item.read! end if user_signed_in?
  end
end
