class MessagesController < ApplicationController
    before_filter :user_in_event

    def create
        # @event = Event.find(params[:event_id])
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

    private
        def user_in_event
            @event = Event.find(params[:event_id])

            if @event.members.include?(current_user)
                true
            else
                flash[:error] = "Trying to do something you're not supposed to...?"
                redirect_to root_path
            end
        end
end
