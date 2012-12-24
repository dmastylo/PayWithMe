class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_event, only: [:show]
  before_filter :user_organizes_event, only: [:edit, :delete, :update]
  
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
      @event.members = members_from_users - members_from_groups
      @member_emails = members_from_users.collect { |member| member.email }
      @event.groups = groups
      @group_ids = @event.groups.collect { |group| group.id }
      render "new"
    end
  end

  def show
  end

  def index
    @organized_events = current_user.organized_events
    @invited_events = current_user.invited_events
  end

  def edit
    @event.members = @event.independent_members
    @member_emails = @event.members.collect { |member| member.email }
    @group_ids = @event.groups.collect { |group| group.id }
  end

  def update
    members_from_users = User.from_params(params[:event].delete(:members))
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    # @event = current_user.organized_events.new(params[:event])

    if @event.update_attributes(params[:event])
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
end