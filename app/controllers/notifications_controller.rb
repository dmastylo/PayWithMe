class NotificationsController < ApplicationController

  def index
    @notifications = current_user.notifications.paginate(page: params[:page], per_page: 15)
  end
  
end