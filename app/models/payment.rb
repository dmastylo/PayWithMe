class Payment < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :amount, :desired_at, :paid_at, :payee_id, :payer_id

  # Validations
  validates :amount, presence: true, numercality: { greater_than: 0 }
  vaildates :payee_id, presence: true
  validates :payer_id, presence: true

end