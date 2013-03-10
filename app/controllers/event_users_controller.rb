class EventUsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :event_public_or_user_organizes_event, only: [:create]
  before_filter :user_owns_event_user, only: [:pay, :pin]
  before_filter :valid_payment_method, only: [:pay]
  before_filter :user_organizes_event, only: [:paid, :unpaid]
  before_filter :user_in_event, only: [:nudge]
  before_filter :event_owns_event_user, only: [:paid, :unpaid, :nudge]
  before_filter :can_nudge_user, only: [:nudge]
  before_filter :event_user_paid_with_cash, only: [:unpaid]
  skip_before_filter :verify_authenticity_token, only: [:ipn]

  def create
    @member = User.find(params[:event_user][:user_id])
    unless @event.members.include?(@member)
      @event.add_member(@member)

      respond_to do |format|
        format.html { redirect_to event_path(@event) } if @event.organizer != current_user # Joining public event
        format.html { redirect_to user_path(@user) }  # Being invited directly
        format.js
      end
    end
  end

  def pay
    payment = @event_user.create_payment(payment_method: params[:method])
    redirect_to payment.url
  end

  def paid
    payment = @event_user.create_payment
    @event_user.pay!(payment)
    respond_to do |format|
      format.js
      format.html { redirect_to admin_event_path(@event) }
    end
  end

  # Mark user as unpaid if he/she paid with cash
  def unpaid
    @event_user.payments.each do |payment|
      if payment.payment_method_id == PaymentMethod::MethodType::CASH
        payment.destroy
      end
    end
    @event_user.paid_at = nil
    @event_user.save
    respond_to do |format|
      format.js
      format.html { redirect_to admin_event_path(@event) }
    end
  end

  def nudge
    @event.nudge!(current_user, @event_user.user)
    respond_to do |format|
      format.js
      format.html { redirect_to event_path(@event) }
    end
  end

private
  def user_owns_event_user
    @event_user = current_user.event_users.find_by_id(params[:id])
    redirect_to root_path unless @event_user.present?
  end

  def event_public_or_user_organizes_event
    @event = Event.find(params[:event_id] || params[:id])
    @user = User.find(params[:event_user][:user_id])
    
    if @event.organizer != current_user
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
    if !@event_user.event.paid_with_cash?(@event_user.user)
      flash[:error] = "Can only mark users who paid with cash as unpaid."
      redirect_to admin_event_path(@event)
    end
  end

  def can_nudge_user
    unless @event.can_nudge?(current_user, @event_user.user)
      flash[:error] = "You can't nudge this user!"
      redirect_to event_path(@event)
    end
  end

  def valid_payment_method
    if PaymentMethod.find_by_id(params[:method]).nil? || !@event_user.event.send_with_payment_method?(params[:method].to_i)
      flash[:error] = "That payment method is no longer accepted."
      redirect_to root_path
    end
  end
end
