class MessagesController < ApplicationController
  before_filter :user_in_event

  def index
    if params[:event_id] && params[:after]
        # Polling for new messages
        @new_messages = Message.where("event_id = ? AND created_at > ?", params[:event_id], Time.at(params[:after].to_i + 1))
        @new_messages.delete_if { |message| message.user == current_user }
    elsif params[:event_id] && params[:last_message_time]
        # Infinite scrolling
        @next_messages = Message.where("event_id = ? AND created_at < ?", params[:event_id], Time.at(params[:last_message_time].to_i)).limit(Figaro.env.chat_msg_per_page.to_i)
        @messages_count = Event.find(params[:event_id]).messages.size unless @next_messages.empty?
    end
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
    else
      render nothing: true
    end
  end
end