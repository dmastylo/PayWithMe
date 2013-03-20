class MessagesController < ApplicationController
  before_filter :user_in_event
  before_filter :user_on_page
  before_filter :clear_relevant_notifications

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
        Event.delay.send_message_notifications(@event.id)
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

private
  def user_on_page
    event_user = current_user.event_users.find_by_event_id(@event.id)
    if event_user.present?
      event_user.update_attribute(:last_seen, Time.now)
    end
  end

  def clear_relevant_notifications
    current_user.notifications.where('foreign_id = ?', @event.id).each do |notification|
      notification.read! if notification.message?
    end

    current_user.news_items.where('foreign_id = ?', @event.id).each do |news_item|
      news_item.read! if news_item.message?
    end
  end
end
