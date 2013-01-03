class PagesController < ApplicationController
    def index
        @upcoming_events = current_user.upcoming_events if user_signed_in?
        @news_items = current_user.news_items if user_signed_in?
    end
end
