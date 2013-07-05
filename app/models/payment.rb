# == Schema Information
#
# Table name: payments
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  paid_at             :datetime
#  payer_id            :integer
#  event_id            :integer
#  amount_cents        :integer
#  processor_fee_cents :integer
#  our_fee_cents       :integer
#  cash                :boolean          default(FALSE)
#  paid_amount_cents   :integer
#  debit_uri           :string(255)
#

class Payment < ActiveRecord::Base
  include ActiveModel::Validations
  
  # Attributes
  attr_accessible :cash, :paid_amount
  [:amount, :paid_amount, :processor_fee, :our_fee].each do |field| monetize "#{field}_cents", allow_nil: true
  end
  
  # Relationships
  belongs_to :payer, class_name: "User"
  belongs_to :event
  has_many :item_users, dependent: :destroy
  accepts_nested_attributes_for :item_users, allow_destroy: true

  # Validations
  validates :payer_id, presence: true
  validates :event_id, presence: true
  validates_with PaymentAmountValidator

  # Callbacks
  before_save :set_status

  # Scopes
  scope :paid,    ->{ where('paid_at IS NOT NULL') }
  scope :unpaid,  ->{ where('paid_at IS NULL') }

  # TODO: Box this validation up somewhere else and make it simpler here
  # validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :paid?
  # validates :processor_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :our_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :transaction_id, presence: true, if: :paid_and_not_cash?

  def paid?
    paid_at.present?
  end

  def unpaid?
    !paid?
  end

  def payee
    self.event.organizer
  end

  def reset!
    reset
    save
  end

  def reset
    self.paid_amount = self.paid_at = self.cash = nil
    # raise self.to_yaml
  end

  def set_status!
    set_status
    save
  end

  def set_status
    self.amount = event.per_person

    if cash? && paid_amount.present?
      if paid_amount == amount && !paid?
        self.paid_at = Time.now
      elsif paid_amount < amount && paid?
        self.paid_at = nil
      end
    end
  end

  def pay!
    hold = self.payer.account.debit(self.amount)
    if hold.is_a?(Balanced::Hold)
      self.debit_uri = hold.debit_uri
      self.paid_at = Time.now
      self.save
      return true
    else
      # Something failed
    end
  end

end
