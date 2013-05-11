class EventsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_event_or_public, only: [:show]
  before_filter :user_organizes_event, only: [:edit, :delete, :destroy, :update, :admin, :guests]
  before_filter :check_organizer_accounts, only: [:show, :admin]
  before_filter :check_user_accounts, only: [:new, :create]
  before_filter :event_user_visit_true, only: [:show]
  before_filter :check_for_payers, only: [:destroy]
  # before_filter :check_event_past, only: [:edit, :update]
  before_filter :clear_relevant_notifications, only: [:show], if: :current_user
  before_filter :update_event_user_status, only: [:show]

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

    if !signed_in?
      session["user_return_to"] = event_path(@event)
    end

    @messages = @event.messages.limit(Figaro.env.chat_msg_per_page.to_i)
    @messages_count = @event.messages.count
    @message = Message.new
    @event_user = @event.event_user(current_user)
    if @event_user.present?
      @payment = @event_user.create_payment if (@event.itemized? || @event.fundraiser?) && !@event_user.paid_at.present?
    else
      @event_user = EventUser.new
    end
  end
  
  def new
    @event = current_user.organized_events.new
    @event.items.new
  end

  def create
    members_from_users = User.from_params(params[:event].delete(:members), current_user)
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    invitation_types = InvitationType.from_params(params[:event].delete(:invitation_types))
    @event = current_user.organized_events.new(params[:event])

    if @event.save
      flash[:success] = "Event created!"

      @event.add_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.add_groups(groups)
      @event.invitation_types = invitation_types

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
    @event.items.new if @event.items.empty?
  end

  def update
    members_from_users = User.from_params(params[:event].delete(:members), current_user)
    groups, members_from_groups = Group.groups_and_members_from_params(params[:event].delete(:groups), current_user)
    invitation_types = InvitationType.from_params(params[:event].delete(:invitation_types))
    # @event.payment_methods = []

    if @event.update_attributes(params[:event])
      flash[:success] = "Event updated!"

      @event.set_members(members_from_users + members_from_groups + [current_user], current_user)
      @event.set_groups(groups)
      @event.invitation_types = invitation_types

      # For some reason, redirect_to @event doesn't work
      redirect_to admin_event_path(@event)
    else
      @member_emails = @event.independent_members.collect { |member| member.email }
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
    @event = Event.find_by_id(@event.id, include: [{ event_users: :user }, :payment_methods] )

    if @event.itemized?
      @items = {}
      @event.items.each do |item|
        item.total_quantity = 0
        @items[item.id] = item
      end

      event_users = @event.payments.where("paid_at IS NOT NULL").includes(:item_users)
      event_users.each do |event_user|
        event_user.item_users.each do |item_user|
          if item_user.quantity.present?
            @items[item_user.item_id].total_quantity += item_user.quantity
          end
        end
      end
    end

    @paid_event_users = @event.paid_event_users(include_items: true)
    @unpaid_event_users = @event.unpaid_event_users
  end

  def guests
    event = Event.find(params[:id])

    respond_to do |format|
      format.pdf do
        pdf = EventPdf.new(event, view_context)
        send_data pdf.render, filename: "#{event.title}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
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
      flash.now[:error] = "Hey! You have to add a PayPal account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>."
    end

    if @event.accepts_dwolla? && @event.organizer.dwolla_account.nil?
      if flash.now[:error].present?
        flash.now[:error] << "<br>"
      else
        flash.now[:error] = ""
      end
      flash.now[:error] << "Hey! You have to add a Dwolla account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>."
    end

    if @event.accepts_wepay? && @event.organizer.wepay_account.nil?
      if flash.now[:error].present?
        flash.now[:error] << "<br>"
      else
        flash.now[:error] = ""
      end
      flash.now[:error] << "Hey! You have to add a WePay account before users can pay for this event. You can do that in <a href=\"#{url_for edit_user_registration_path}\">Account Settings</a>."
    end

    if @event.payment_methods.empty?
      flash.now[:error] = "Hey! You haven't set any payment methods so no one can pay for this event. You can do that by <a href=\"#{url_for edit_event_path(@event)}\">editing the event</a>."
    end
    flash.now[:error] = flash.now[:error].html_safe unless flash.now[:error].nil?
  end

  def check_user_accounts
    if current_user.linked_accounts.where(provider: [:wepay, :paypal, :dwolla]).empty? && !current_user.using_cash?
      flash[:error] = "You need to set up payment options before creating an event."
      redirect_to linked_accounts_path
    end
  end

  # def check_event_past
  #   if @event.is_past?
  #     flash[:error] = "You can't edit an event that has already happened."
  #     redirect_to event_path(@event)
  #   end
  # end

  def update_event_user_status
    if params[:success] == '1' && signed_in?
      if params[:checkout_id]
        payment = current_user.sent_payments.find_by_transaction_id_and_event_id(params[:checkout_id], @event.id)
      else
        payment = current_user.sent_payments.find_by_event_id(@event.id)
      end
      return unless payment.present?
      payment.update! 
      @event_user.update_status
      @event_user.save
      @event_user.reload

      if [EventUser::Status::PAID, EventUser::Status::PENDING].include?(@event_user.status)
        @unpaid_event_users = @event.unpaid_event_users
        if !@unpaid_event_users.empty? && @event.nudges_remaining(current_user) > 0
          @display_nudge_modal = true
        end
        @event_user.reload
      end
    end
  end
end
