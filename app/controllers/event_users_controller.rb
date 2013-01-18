class EventUsersController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :event_public_or_user_organizes_event, only: [:create]
  before_filter :user_owns_event_user, only: [:pay, :pin]
  before_filter :valid_payment_method, only: [:pay]
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

  def pay
    payment = Payment.create_or_find_from_event_user(@event_user, params[:method])
    result = payment.pay!(params[:pin])

    if result == :back_to_pin
      flash[:error] = payment.error_message
      redirect_to pin_event_user_path(@event_user, method: PaymentMethod::MethodType::DWOLLA)
    elsif result == :back_to_event
      flash[:success] = "Payment received!"
      redirect_to event_path(@event_user.event)
    elsif result.present?
      redirect_to result
    end
  end

  def pin
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

  def valid_payment_method
    if !(["2", "3"].include? params[:method]) || !@event_user.event.send_with_payment_method?(params[:method].to_i)
      flash[:error] = "That payment method is no longer accepted."
      redirect_to root_path
    end
  end
end