class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_in_event, only: [:show]
  before_filter :user_organizes_event, only: [:edit, :delete]
  
  def new
    @event = current_user.organized_events.new
  end

  def create
    members_from_users = User.from_params(params[:event].delete(:members))
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    @event = current_user.organized_events.new(params[:event])

    if @event.save
      flash[:success] = "Event created!"

      @event.add_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.add_groups(groups)

      # For some reason, redirect_to @event doesn't work
      redirect_to event_path(@event)
    else
      render "new"
    end
  end

  def show
    # @messages = @event.messages.all # TODO: infinite scroll
  end

  def index
    @events = current_user.member_events
  end

  def edit
    @event.members = @event.independent_members
    @member_emails = @event.members.collect { |member| member.email }
    @group_ids = @event.groups.collect { |group| group.id }
  end

  def update
    members_from_users = User.from_params(params[:event].delete(:members))
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    @event = current_user.organized_events.new(params[:event])

    if @event.save
      flash[:success] = "Event updated!"

      @event.add_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.add_groups(groups)

      # For some reason, redirect_to @event doesn't work
      redirect_to event_path(@event)
    else
      @event.members = @event.independent_members
      @member_emails = @event.members.collect { |member| member.email }
      @group_ids = @event.groups.collect { |group| group.id }
      render "edit"
    end
  end

private
  def user_in_event
    @event = current_user.member_events.find_by_id(params[:id])

    if @event.nil?
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end

  def user_organizes_event
    @event = current_user.organized_events.find_by_id(params[:id])

    if @event.nil?
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end
end