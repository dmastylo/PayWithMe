# == Schema Information
#
# Table name: payment_methods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  payment_method :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PaymentMethod < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :payment_method

  # Validations
  validates :event_id, presence: true
  validates :payment_method, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }

  # Relationships
  belongs_to :event

  # Constants
  class MethodType
    CASH = 1
    PAYPAL = 2
    DWOLLA = 3
  end

end
