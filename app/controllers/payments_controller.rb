class PaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:ipn]
  before_filter :user_owns_payment, except: [:ipn]
  before_filter :valid_payment_method_for_pin, only: [:pin]

  def pin
  end

  def pay
    if @payment.payment_method_id == PaymentMethod::MethodType::DWOLLA
      if params[:pin].empty?
        flash[:error] = "Please enter your pin."
        render "pin"
        return
      else
        dwolla_user = Dwolla::User.me(@payment.payer.dwolla_account.token)
        begin
          transaction_id = dwolla_user.send_money_to(@payment.payee.dwolla_account.uid, @payment.total_amount.to_f, params[:pin], nil, "Payment for #{@payment.event.title}", nil, true)
        rescue Exception => e
          flash[:error] = e.message
          render "pin"
          return
        end

        @payment.update!
        redirect_to event_path(@payment.event, success: 1)
      end
    end
  end

  def ipn
    @payment = Payment.find_by_id(params[:id])
    return unless @payment.present?

    if @payment.payment_method_id == PaymentMethod::MethodType::PAYPAL
      notify = ActiveMerchant::Billing::Integrations::PaypalAdaptivePayment::Notification.new(request.raw_post)
      event_user = Payment.find_by_id(params[:id])
      if notify.acknowledge && @payment.transaction_id == params["transaction"]["0"][".id"] # A sanity check to make sure that we're talking about the same payment, not sure if necessary
        @payment.update!
      end
    elsif @payment.payment_method_id == PaymentMethod::MethodType::WEPAY
      if @payment.transaction_id == params[:checkout_id] # See above comment
        @payment.update!
      end
    elsif @payment.payment_method_id == PaymentMethod::MethodType::DWOLLA
      raise "PaymentsController::ipn is not yet defined for Dwolla payments."
    end
  end

private
  def user_owns_payment
    @payment = current_user.sent_payments.find_by_id(params[:id])
    redirect_to root_path unless @payment.present?
  end

  def valid_payment_method_for_pin
    redirect_to root_path unless @payment.payment_method.name == "Dwolla"
    unless current_user.dwolla_account.present?
      flash[:error] = "Please link your Dwolla account before paying with Dwolla."
      redirect_to edit_user_registration_path
    end
  end

end