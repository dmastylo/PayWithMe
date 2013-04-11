class WithdrawalsController < ApplicationController
  
  def ipn
    @withdrawal = Withdrawal.find_by_id(params[:id])
    return unless @withdrawal.present?

    if @withdrawal.transaction_id == params[:withdrawal_id]
      gateway = Payment.wepay_gateway
      response = gateway.call('/withdrawal', @withdrawal.linked_account.token_secret,
      {
        withdrawal_id: @withdrawal.transaction_id
      })

      @withdrawal.status = response["state"]
      @withdrawal.amount_cents = response["amount"].to_f * 100

      @withdrawal.save
    end

  end

end
