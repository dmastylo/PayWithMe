class MessagesController < ApplicationController
    before_filter :user_in_event

    def index
        @new_messages = Message.where("event_id = ? AND created_at > ?", params[:event_id], Time.at(params[:after].to_i + 1))
    end

    def create
        if Time.now.to_i - @event.messages.first.created_at.to_i > Figaro.env.chat_limit.to_i
            @message = @event.messages.create(params[:message])
            @message.user = current_user
            if @message.save
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

    private
        def user_in_event
            @event = current_user.member_events.find_by_id(params[:event_id])

            if @event.nil?
                flash[:error] = "Trying to do something you're not supposed to...?"
                redirect_to root_path
            end
        end
end
