class LinkedAccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_owns_linked_account, only: [:destroy, :transactions, :show, :balance, :withdraw]
  before_filter :account_is_wepay, only: [:transactions, :show, :balance, :withdraw]

  def index
    session["user_return_to"] = new_event_path
  end

  def cash
    current_user.using_cash = true
    current_user.save
    redirect_to new_event_path
  end

  def destroy
    if current_user.linked_accounts.count > 1 || current_user.encrypted_password.present?
      @linked_account.destroy
      flash[:success] = "#{@linked_account.provider.humanize} account successfully unlinked!"
    else
      flash[:error] = "You need to keep at least one linked account in order to sign in."
    end
    redirect_to edit_user_registration_path
  end

  def show
    @payments = current_user.received_payments.where(payment_method_id: PaymentMethod::MethodType::WEPAY, status_type: Payment::StatusType::PAID).order('updated_at DESC').limit(10).includes(:payer, :event)
    @withdrawals = current_user.wepay_account.withdrawals.where('status <> "new"').order('updated_at DESC').limit(10)
  end

  def payments
    @payments = current_user.received_payments.where(payment_method_id: PaymentMethod::MethodType::WEPAY, status_type: Payment::StatusType::PAID).order('updated_at DESC').paginate(page: params[:page]).includes(:payer, :event)
  end

  def balance
    # Force disallowing updating balance more than once per minute
    if @linked_account.balanced_at.nil? || (Time.now - @linked_account.balanced_at) > Figaro.env.balance_update_minimum.to_i
      @linked_account.update_balance
      flash[:success] = "Balance updated!"
    else
      flash[:error] = "Wait a second, after updating your balance you must wait a minute before updating again."
    end
    redirect_to linked_account_path(@linked_account)
  end

  def withdraw
    # @linked_account.withdrawals.where('amount_cents IS NULL AND status = "new"').destroy_all
    withdrawal = @linked_account.withdrawals.create

    gateway = Payment.wepay_gateway
    response = gateway.call('/withdrawal/create', @linked_account.token_secret,
    {
      account_id: @linked_account.token,
      callback_uri: ipn_withdrawal_url(withdrawal),
      mode: 'iframe'
    })

    if response["error_description"]
      if response["error_description"].include?("send_money")
        response["error_description"] = "Please unlink and relink your WePay account to withdraw from PayWithMe."
      end
      flash[:error] = "WePay returned the following error when attempting to withdraw: #{response["error_description"]}"
      redirect_to linked_account_path(@linked_account)
    end

    withdrawal.update_attributes(transaction_id: response["withdrawal_id"])
    @iframe_url = response["withdrawal_uri"]
  end

private
  def user_owns_linked_account
    @linked_account = current_user.linked_accounts.find_by_id(params[:id])
    redirect_to root_path unless @linked_account.present?
  end

  def account_is_wepay
    redirect_to root_path unless @linked_account.provider == "wepay"
  end
end