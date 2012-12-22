class PagesController < ApplicationController
    def index
        @upcoming_events = current_user.upcoming_events
    end
end
