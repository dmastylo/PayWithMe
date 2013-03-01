# == Schema Information
#
# Table name: payment_methods
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  static_fee_cents    :integer
#  percent_fee         :decimal(, )
#  minimum_fee_cents   :integer
#  fee_threshold_cents :integer
#  name                :string(255)
#

class PaymentMethod < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :id, :name, :static_fee_cents, :percent_fee, :minimum_fee_cents, :fee_threshold_cents

  def processor_fee(amount)
    fee = 0
    if amount >= fee_threshold_cents
      fee = (amount + static_fee_cents) / ((100.0 - percent_fee.to_f) / 100.0) - amount
    end
    if fee < minimum_fee_cents
      fee = minimum_fee_cents
    end
    return fee.round
  end

  def our_fee(amount)
    0
  end

  def processor_fee_after_our_fee(amount)
    processor_fee(amount + our_fee(amount))
  end

  def total_fee(amount)
    processor_fee(amount + our_fee(amount)) + our_fee(amount)
  end

  def total_amount(amount)
    amount + total_fee(amount)
  end

  # Validations
  # validates :event_id, presence: true
  # validates :payment_method, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }

  # Relationships
  has_and_belongs_to_many :events

  # Constants
  class MethodType
    def self.const_missing(const)
      if :CASH == const
        1 # PaymentMethod.find_by_name("Cash").id
      elsif :PAYPAL == const
        2 # PaymentMethod.find_by_name("PayPal").id
      elsif :DWOLLA == const
        3 # PaymentMethod.find_by_name("Dwolla").id
      elsif :WEPAY == const
        4 # PaymentMethod.find_by_name("WePay").id
      else
        super(const)
      end
    end
  end

end
