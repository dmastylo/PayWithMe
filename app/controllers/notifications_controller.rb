class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.paginate(page: params[:page])
  end
end