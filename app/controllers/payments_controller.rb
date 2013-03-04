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
          trans_id = dwolla_user.send_money_to(@payment.payee.dwolla_account.uid, @payment.total_amount.to_f, params[:pin], nil, "Payment for #{@payment.event.title}", nil, true)
        rescue Exception => e
          flash[:error] = e.message
          render "pin"
          return
        end

        @payment.event_user.pay!(@payment, transaction_id: trans_id)
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
      if notify.acknowledge && @payment.present?
        if notify.complete?
          @payment.event_user.pay!(@payment, transaction_id: params["transaction"]["1"][".id"])
        else
          # Nothing for now
        end
      end
    elsif @payment.payment_method_id == PaymentMethod::MethodType::WEPAY
      if @payment.transaction_id == params[:checkout_id]
        gateway = Payment.wepay_gateway
        response = gateway.call('/checkout', @payment.payee.wepay_account.token_secret,
        {
          checkout_id: @payment.transaction_id
        })

        if ["captured", "authorized"].include?(response["state"])
          @payment.event_user.pay!(@payment, transaction_id: @payment.transaction_id)
        else
          @payment.event_user.unpay!(@payment)
        end
      end
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