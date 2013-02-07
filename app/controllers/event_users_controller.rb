class EventUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :event_public_or_user_organizes_event, only: [:create]
  before_filter :user_owns_event_user, only: [:pay, :pin]
  before_filter :valid_payment_method, only: [:pay]
  before_filter :user_organizes_event, only: [:paid, :unpaid]
  before_filter :event_owns_event_user, only: [:paid, :unpaid]
  before_filter :event_user_paid_with_cash, only: [:unpaid]
  skip_before_filter :verify_authenticity_token, only: [:ipn]

  def create
    # for some reason member_ids.include? does not work
    unless @event.members.include?(User.find(params[:event_user][:user_id]))
      @event_user = EventUser.create(params[:event_user])
      NewsItem.create_for_new_event_member(@event, @event_user.user)
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
    payment = @event_user.create_payment(payment_method: params[:method])
    redirect_to payment.url
  end

  def paid
    payment = Payment.create_or_find_from_event_user(@event_user, PaymentMethod::MethodType::CASH)
    payment.update_attributes(paid_at: Time.now)
    @event_user.update_attributes(paid_at: Time.now)
    respond_to do |format|
      format.js
      format.html { redirect_to admin_event_path(@event) }
    end
  end

  # Mark user as unpaid if he/she paid with cash
  def unpaid
    Payment.where(payer_id: @event_user.member.id).first.delete
    @event_user.update_attributes(paid_at: nil)
    respond_to do |format|
      format.js
      format.html { redirect_to admin_event_path(@event) }
    end
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
          flash[:error] = "Trying to hack...?" #{params[:event_user][:user_id]} #{current_user.id}"
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

  def event_user_paid_with_cash
    if @event_user.payment.payment_method != PaymentMethod::MethodType::CASH
      flash[:error] = "Can only mark users who paid with cash as unpaid."
      redirect_to admin_event_path(@event)
    end
  end

  def valid_payment_method
    if PaymentMethod.find_by_id(params[:method]).nil? || !@event_user.event.send_with_payment_method?(params[:method].to_i)
      flash[:error] = "That payment method is no longer accepted."
      redirect_to root_path
    end
  end
end
