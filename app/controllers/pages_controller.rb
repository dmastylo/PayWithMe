class PagesController < ApplicationController
  after_filter :read_news_items, only: [:index]
  before_filter :redirect_to_user_home

  caches_action :index
  caches_page :team, :faq, :privacy_policy

private
  def read_news_items
    @news_items.each do |news_item| news_item.read! end if user_signed_in?
  end

  def redirect_to_user_home
    redirect_to home_users_path if signed_in?
  end
end
