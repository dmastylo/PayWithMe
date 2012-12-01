class MessagesController < ApplicationController
    def create
        @event = Event.find(params[:event_id])
        @message = @event.messages.create(params[:message])
        @message.user = current_user
        if @message.save
            flash[:success] = "Message created!"
            redirect_to event_path(@event)
        else
            flash[:error] = "Message failed!"
            redirect_to event_path(@event)
        end
    end
end
