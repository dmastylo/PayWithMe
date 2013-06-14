class PaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :ensure_payment_is_unpaid!, only: [:pay, :paid]
  before_filter :ensure_user_can_pay_payment!, only: [:pay, :paid]
  before_filter :ensure_payment_is_paid!, only: [:unpaid]
  before_filter :ensure_payment_is_cash!, only: [:unpaid]
  # before_filter :ensure_user_owns_payment!, except: [:ipn]

  def pay
    @event_user = @payment.event_user
    @event = @event_user.event
  end

  def paid
    params[:payment][:paid_amount] = @payment.amount if params[:payment][:paid_amount].empty? # blank form is full payment
    if @payment.update_attributes!(params[:payment])
      if @payment.cash?
        @payment.event_user.set_status!
        render json: { html: render_to_string("paid", layout: false), method: "replace", destination: "js-paid" }
      else
        # User submitting credit card form
        # TODO
      end
    else
      # Validation failure
      if @payment.payer_id == current_user.id # (and request is for JSON)
        # Show credit card form
        render "pay"
      else
        # Respond to JSON request
        render json: @payment.errors, status: :unprocessable_entity
      end
    end
  end

  def unpaid
    @payment.reset!
    @payment.event_user.set_status!
    render json: { html: render_to_string("unpaid", layout: false), method: "replace", destination: "js-unpaid" }
  end

  # def items
  #   @payment.event_user.clean_up_payments!(@payment.id)

  #   if @payment.update_attributes(params[:payment].slice(:item_users_attributes, :payment_method_id))
  #     if @payment.update_for_items!
  #       redirect_to @payment.url
  #     else
  #       flash[:error] = "Please select valid quantities of each item."
  #       redirect_to event_path(@payment.event)
  #     end
  #   end
  # end

  def ipn
  end

private
  def ensure_user_owns_payment!
    @payment ||= Payment.find_by_id(params[:id])
    redirect_to root_path unless @payment.payer_id == current_user.id
  end

  def ensure_payment_is_unpaid!
    @payment ||= Payment.find_by_id(params[:id])
    redirect_to root_path unless @payment.paid_at.nil?
  end

  def ensure_payment_is_paid!
    @payment ||= Payment.find_by_id(params[:id])
    redirect_to root_path unless @payment.paid_at.present?
  end

  def ensure_payment_is_cash!
    @payment ||= Payment.find_by_id(params[:id])
    redirect_to root_path unless @payment.cash?
  end

  def ensure_user_can_pay_payment!
    # User can pay (electronic/cash) if they own the payment (electronic) or if they organize the event (cash)
    @payment ||= Payment.find_by_id(params[:id])
    using_cash = params[:payment].present? && params[:payment][:cash]
    redirect_to root_path unless (@payment.payer_id == current_user.id && !using_cash) || (@payment.event.organizer_id = current_user.id && using_cash)
  end
end