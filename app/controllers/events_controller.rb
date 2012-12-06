class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_in_event, only: [:show]
  
  def new
    @event = current_user.organized_events.new
  end

  def create
    members = ActiveSupport::JSON.decode(params[:event].delete(:members))
    groups = ActiveSupport::JSON.decode(params[:event].delete(:groups))
    @event = current_user.organized_events.new(params[:event])
    members.each do |member|
      user = User.find_by_email(member)
      if user.nil?
        user = User.new(email: member)
        user.stub = true
        user.save
      end

      @event.members << user
    end

    groups.each do |group|
      group = current_user.groups.find_by_id(group)
      if group.present?
        group.members.each do |member|
          puts member
          if !@event.members.include?(member)
            @event.members << member
          end
        end
      end
    end
    @event.members << current_user unless @event.members.include?(current_user)

    if @event.save
      flash[:success] = "Event created!"

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