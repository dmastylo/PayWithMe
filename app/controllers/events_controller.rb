class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_in_event, only: [:show]
  
  def new
    @event = current_user.organized_events.new
  end

  def create
    @event = current_user.organized_events.new(params[:event])

    if @event.save
      flash[:success] = "Event created!"
      redirect_to @event
    else
      render "new"
    end
  end

  def show
    @event = Event.find(params[:id])
    @members = @event.members
    @messages = @event.messages.all
  end

  private
      def user_in_event
          @event = Event.find(params[:id])

          if @event.members.include?(current_user) || @event.organizer == current_user
              true
          else
              flash[:error] = "You're not on the list."
              redirect_to root_path
          end
      end
end