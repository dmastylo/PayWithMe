class EventUsersController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :user_organizes_event, only: [:create]
  before_filter :user_owns_event_user, only: [:pay]
  skip_before_filter :verify_authenticity_token, only: [:ipn]

  def create
    # for some reason member_ids.include? does not work
    unless @event.members.include?(User.find(params[:event_user][:user_id]))
      @event_user = EventUser.create(params[:event_user])
      NewsItem.create_for_new_event_member(@event, @event_user.member)
      if @event_user.save
        @event.set_event_user_attributes(current_user)

        respond_to do |format|
          format.html { redirect_to user_path(@user) }
          format.js
        end
      else
        flash[:error] = "Adding user failed!"
        redirect_to user_path(@user)
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

private
  def user_owns_event_user
    @event_user = current_user.event_users.find_by_id(params[:id])
    redirect_to root_path unless @event_user.present?
  end
end
