class PaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :user_owns_payment, except: [:ipn]
  before_filter :valid_payment_method_for_pin, only: [:pin]
  before_filter :valid_payment_method_for_items_or_fundraiser, only: [:items, :fundraiser]
  before_filter :payment_is_unpaid, only: [:items, :fundraiser]
  before_filter :event_is_itemized, only: [:items]
  before_filter :event_is_fundraiser, only: [:fundraiser]

  def pin
  end

  def pay
  end

  def items
    @payment.event_user.clean_up_payments!(@payment.id)

    if @payment.update_attributes(params[:payment].slice(:item_users_attributes, :payment_method_id))
      if @payment.update_for_items!
        redirect_to @payment.url
      else
        flash[:error] = "Please select valid quantities of each item."
        redirect_to event_path(@payment.event)
      end
    end
  end

  def fundraiser
  end

  def ipn
  end

private
  def user_owns_payment
    @payment = current_user.sent_payments.find_by_id(params[:id])
    redirect_to root_path unless @payment.present?
  end

  def payment_is_unpaid
    redirect_to root_path unless @payment.paid_at.nil?
  end

  def event_is_itemized
    redirect_to root_path unless @payment.event.itemized?
  end

  def event_is_fundraiser
    redirect_to root_path unless @payment.event.fundraiser?
  end

end