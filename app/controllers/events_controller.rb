class EventsController < ApplicationController
  before_filter :authenticate_user!
  
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
end