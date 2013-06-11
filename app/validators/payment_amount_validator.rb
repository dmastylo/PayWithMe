class PaymentAmountValidator < ActiveModel::Validator
  def validate(payment)
    unless payment.amount_cents > 0
      payment.errors[:amount] = "must be greater than zero"
    end
    unless payment.paid_amount_cents.nil?
      unless payment.paid_amount_cents >= 0
        payment.errors[:paid_amount] = "must be greater than or equal to zero"
      end
      unless payment.paid_amount_cents <= payment.amount_cents
        payment.errors[:paid_amount] = "cannot exceed total"
      end
    end
  end
end