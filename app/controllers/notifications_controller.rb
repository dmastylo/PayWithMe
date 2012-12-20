class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notifications = current_user.notifications.paginate(page: params[:page])
  end

  def read
    current_user.unread_notifications.each do |notification|
      notification.read!
    end
  end
end
