class MessagesController < ApplicationController
  before_filter :user_in_event

  def index
    @new_messages = Message.where("event_id = ? AND created_at > ?", params[:event_id], Time.at(params[:after].to_i + 1))
    @new_messages.delete_if { |message| message.user == current_user }
  end

  def create
    if current_user.can_post_message?
      @message = @event.messages.create(params[:message])
      @message.user = current_user
      if @message.save
        @event.delay.send_message_notifications
        respond_to do |format|
          format.html { redirect_to event_path(@event) }
          format.js
        end
      else
        flash[:error] = "Message failed!"
        redirect_to event_path(@event)
      end
    end
  end
end