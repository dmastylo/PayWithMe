class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_event, only: [:show]
  before_filter :user_organizes_event, only: [:edit, :delete, :destroy, :update, :admin]
  before_filter :event_user_vist_true, only: [:show]
  before_filter :check_for_payers, only: :destroy

  def index
    @upcoming_events = current_user.upcoming_events
    @past_events = current_user.past_events
  end

  def show
    if request.path != event_path(@event)
      redirect_to event_path(@event), status: :moved_permanently
    end

    @messages = @event.messages.limit(Figaro.env.chat_msg_per_page.to_i)
    @messages_count = @event.messages.size
    @message = Message.new
    @event_user = EventUser.new unless @event.members.include?(current_user)
  end
  
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

  def edit
    @member_emails = @event.independent_members.collect { |member| member.email }
    @group_ids = @event.groups.collect { |group| group.id }
  end

  def update
    members_from_users = User.from_params(params[:event].delete(:members))
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    # raise [members_from_users, '=====', members_from_groups].to_yaml
    # @event = current_user.organized_events.new(params[:event])

    if @event.update_attributes(params[:event])
      flash[:success] = "Event updated!"

      @event.set_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.set_groups(groups)

      # For some reason, redirect_to @event doesn't work
      redirect_to event_path(@event)
    else
      @event.members = @event.independent_members
      @member_emails = @event.members.collect { |member| member.email }
      @group_ids = @event.groups.collect { |group| group.id }
      render "edit"
    end
  end

  def destroy
    @event.destroy
    flash[:success] = "Event deleted!"
    redirect_to events_path
  end

  def admin
  end

private
  def event_user_vist_true
    if @event.members.include?(current_user)
      @event_user = @event.event_users.find_by_user_id(current_user.id)
      @event_user.visit_event!
    end
  end

  def check_for_payers
    unless @event.paid_members.empty?
      flash[:error] = "You can't delete an event with paying members!"
      redirect_to event_path(@event)
    end
  end
end
