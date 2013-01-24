class EventUsersController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :event_public_or_user_organizes_event, only: [:create]
  before_filter :user_owns_event_user, only: [:pay]
  before_filter :user_organizes_event, only: [:paid]
  before_filter :event_owns_event_user, only: [:paid]
  skip_before_filter :verify_authenticity_token, only: [:ipn]

  def create
    # for some reason member_ids.include? does not work
    unless @event.members.include?(User.find(params[:event_user][:user_id]))
      @event_user = EventUser.create(params[:event_user])
      NewsItem.create_for_new_event_member(@event, @event_user.member)
      if @event_user.save
        @event.set_event_user_attributes(current_user)

        respond_to do |format|
          format.html { redirect_to event_path(@event) } if @event_organizer.nil? # Joining public event
          format.html { redirect_to user_path(@user) }  # Being invited directly
          format.js
        end
      else
        flash[:error] = "Adding user failed!"
        redirect_to event_path(@event) if @event_organizer.nil? # Joining public event
        redirect_to user_path(@user) # Being invited directly
      end
    end
  end

  def pay
    payment = Payment.create_or_find_from_event_user(@event_user)
    redirect_to payment.pay!
  end

  def ipn
    notify = ActiveMerchant::Billing::Integrations::PaypalAdaptivePayment::Notification.new(request.raw_post)
    event_user = EventUser.find_by_id(params[:id])
    if notify.acknowledge && event_user.present?
      if notify.complete?
        event_user.paid_at = Time.now
        event_user.payment.paid_at = Time.now
        event_user.payment.save
        event_user.save
      else
        # Nothing for now
      end
    end
  end

  def paid
    payment = Payment.create_or_find_from_event_user(@event_user)
    payment.paid_at = Time.now
    payment.save
    @event_user.paid_at = Time.now
    @event_user.save
    redirect_to admin_event_path(@event)
  end

private
  def user_owns_event_user
    @event_user = current_user.event_users.find_by_id(params[:id])
    redirect_to root_path unless @event_user.present?
  end

  def event_public_or_user_organizes_event
    @event_organizer = current_user.organized_events.find_by_id(params[:event_id] || params[:id])
    @event = Event.find(params[:event_id] || params[:id])
  
    if @event_organizer.nil?
      # If user doesn't organize event, it must be public and the user_id must be equal to current_user
      if @event.public?
        if params[:event_user][:user_id].to_i != current_user.id
          flash[:error] = "Trying to hack...? #{params[:event_user][:user_id]} #{current_user.id}"
          redirect_to root_path
        end
      else
        flash[:error] = "Not a public event."
        redirect_to root_path
      end
    end
  end

  def event_owns_event_user
    @event_user = @event.event_users.find_by_id(params[:id])
    redirect_to root_path unless @event_user.present?
  end
end
