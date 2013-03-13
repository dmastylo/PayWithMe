class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_event_or_public, only: [:show]
  before_filter :user_organizes_event, only: [:edit, :delete, :destroy, :update, :admin]
  before_filter :check_organizer_accounts, only: [:show, :admin]
  before_filter :event_user_visit_true, only: [:show]
  before_filter :check_for_payers, only: [:destroy]
  before_filter :check_event_past, only: [:edit, :update]
  before_filter :clear_relevant_notifications, only: [:show], if: :current_user

  def index
    @upcoming_events = current_user.upcoming_events
    @past_events = current_user.past_events
  end

  def show
    if request.path != event_path(@event)
      redirect_to event_path(@event), status: :moved_permanently
    end

    @event = Event.find_by_id(@event.id, include: { event_users: :user } )

    if params[:success]
      flash.now[:success] = "Payment received! If everything went well, you should be marked as paid shortly (if not already)."
    elsif params[:cancel]
      flash.now[:error] = "Payment cancelled!"
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
    members_from_users = User.from_params(params[:event].delete(:members), current_user)
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
    members_from_users = User.from_params(params[:event].delete(:members), current_user)
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)

    if @event.update_attributes(params[:event])
      flash[:success] = "Event updated!"

      @event.set_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.set_groups(groups)

      # For some reason, redirect_to @event doesn't work
      redirect_to admin_event_path(@event)
    end
  end

  def destroy
    @event.destroy
    flash[:success] = "Event deleted!"
    redirect_to events_path
  end

  def admin
    @event = Event.find_by_id(@event.id, include: [{ event_users: :user }, :payment_methods] )
  end

private
  def event_user_visit_true
    if @event.members.include?(current_user)
      @event_user = @event.event_users.find_by_user_id(current_user.id)
      @event_user.visit_event!
    end
  end

  def check_for_payers
    unless @event.paid_members.empty?
      flash[:error] = "You can't delete an event with paid members!"
      redirect_to admin_event_path(@event)
    end
  end

  def clear_relevant_notifications
    current_user.notifications.where('foreign_id = ?', @event.id).each do |notification|
      notification.read!
    end

    current_user.news_items.where('foreign_id = ?', @event.id).each do |news_item|
      news_item.read!
    end
  end

  def check_organizer_accounts
    return unless current_user == @event.organizer
    if @event.accepts_paypal? && @event.organizer.paypal_account.nil?
      flash.now[:error] = "Hey! You have to add a PayPal account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>.".html_safe
    end

    if @event.accepts_dwolla? && @event.organizer.dwolla_account.nil?
      flash.now[:error] = "Hey! You have to add a Dwolla account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>.".html_safe
    end

    if @event.accepts_wepay? && @event.organizer.wepay_account.nil?
      flash.now[:error] = "Hey! You have to add a WePay account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>.".html_safe
    end
  end

  def check_event_past
    if @event.is_past?
      flash[:error] = "You can't edit an event that has already happened."
      redirect_to event_path(@event)
    end
  end
end
