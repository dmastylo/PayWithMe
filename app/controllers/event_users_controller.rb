class EventUsersController < ApplicationController
  before_filter :event_public_or_user_organizes_event

  def create
    # for some reason member_ids.include? does not work
    unless @event.members.include?(User.find(params[:event_user][:user_id]))
      @event_user = EventUser.create(params[:event_user])
      NewsItem.create_for_new_event_member(@event, @event_user.member)
      if @event_user.save
        @event.set_event_user_attributes(current_user)

        respond_to do |format|
          format.html { redirect_to event_path(@event) } if @event_organizer.nil?
          format.html { redirect_to user_path(@user) }
          format.js
        end
      else
        flash[:error] = "Adding user failed!"
        redirect_to event_path(@event) if @event_organizer.nil?
        redirect_to user_path(@user)
      end
    end
  end

private
  def event_public_or_user_organizes_event
    @event_organizer = current_user.organized_events.find_by_id(params[:event_id] || params[:id])
    @event = Event.find(params[:event_id] || params[:id])
  
    if @event_organizer.nil?
      # If user doesn't organize event, it must be public and the user_id must be equal to current_user
      @public_event = Event.find(params[:event_id] || params[:id]).public?
  
      if @public_event
        if User.find(params[:event_user][:user_id]) != current_user
            flash[:error] = "Trying to hack...?"
            redirect_to root_path
        end
      else
        flash[:error] = "Not a public event."
        redirect_to root_path
      end
    end
  end
end