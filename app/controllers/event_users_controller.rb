class EventUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_event_public_or_user_organizes_event!, only: [:create]
  before_filter :ensure_event_owns_event_user!, only: [:nudge]
  before_filter :ensure_event_user_can_nudge!, only: [:nudge]
  # skip_before_filter :verify_authenticity_token, only: [:ipn]

  def create
    @member = User.find(params[:event_user][:user_id])
    unless @event.members.include?(@member)
      @event.add_member(@member)

      respond_to do |format|
        format.html { redirect_to event_path(@event) } if @event.organizer != current_user # Joining public event
        format.html { redirect_to user_path(@user) }  # Being invited directly
        format.js
      end
    end
  end

  def nudge
    @nudgee_event_user = @event_user
    @nudger_event_user = @event.event_user_of(current_user)

    @event.nudge!(current_user, @nudgee_event_user.user)
    @nudger_event_user.update_nudges_remaining
    respond_to do |format|
      format.js
      format.html { redirect_to event_path(@event) }
    end
  end

private
  def ensure_event_public_or_user_organizes_event!
    @event = Event.find(params[:event_id] || params[:id])
    @user = User.find(params[:event_user][:user_id])
    
    if @event.organizer != current_user
      # If user doesn't organize event, it must be public and the user_id must be equal to current_user
      if @event.public? 
        if (!@event.members.include?(current_user) && params[:event_user][:user_id].to_i != current_user.id)
          flash[:error] = "Trying to hack...?" #{params[:event_user][:user_id]} #{current_user.id}"
          redirect_to root_path
        end
      else
        flash[:error] = "Not a public event."
        redirect_to root_path
      end
    end
  end

  def ensure_event_owns_event_user!
    @event_user = @event.event_users.find_by_id(params[:id])
    redirect_to root_path unless @event_user.present?
  end

  def ensure_event_user_can_nudge!
    unless @event.can_nudge?(current_user, @event_user.user)
      flash[:error] = "You can't nudge this user!"
      redirect_to event_path(@event)
    end
  end
end
