class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_in_event, only: [:show]
  
  def new
    @event = current_user.organized_events.new
  end

  def create
    members_from_users = User.from_params(params[:event].delete(:members))
    members_from_groups = Group.users_from_params(params[:event].delete(:groups), current_user)
    @event = current_user.organized_events.new(params[:event])

    if @event.save
      flash[:success] = "Event created!"

      [members_from_users, members_from_groups].each do |members|
        members.each do |member|
          @event.members << member unless @event.members.include?(member)
        end
      end

      @event.members << current_user unless @event.members.include?(current_user)
      @event.event_users.each do |event_user|
        if event_user.member != current_user
          event_user.due_date = @event.due_at
          event_user.amount_cents = @event.send_amount_cents
          event_user.save
        end
      end

      # For some reason, redirect_to @event doesn't work
      redirect_to event_path(@event)
    else
      render "new"
    end
  end

  def show
    @event = Event.find(params[:id])
    @members = @event.members
    @messages = @event.messages.all
  end

  def index
    @events = current_user.member_events
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