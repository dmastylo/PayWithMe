# == Schema Information
#
# Table name: payments
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  requested_at               :datetime
#  paid_at                    :datetime
#  due_at                     :datetime
#  payer_id                   :integer
#  payee_id                   :integer
#  event_id                   :integer
#  amount_cents               :integer
#  event_user_id              :integer
#  transaction_id             :string(255)
#  processor_fee_amount_cents :integer
#  our_fee_amount_cents       :integer
#  payment_method_id          :integer
#  status                     :string(255)      default("new")
#  status_type                :integer
#

class Payment < ActiveRecord::Base
  
  # Accessible attributes
  # There is no available create route right now so we
  # can get away with things that shouldn't be accessible
  attr_accessible :error_message, :payer_id, :payee_id, :event_id, :amount, :amount_cents, :processor_fee_amount_cents, :our_fee_amount_cents, :due_at, :requested_at, :event_user_id, :paid_at, :item_users_attributes
  attr_accessor :error_message
  monetize :amount_cents, allow_nil: true
  monetize :processor_fee_amount_cents, allow_nil: true
  monetize :our_fee_amount_cents, allow_nil: true
  monetize :total_amount_cents, allow_nil: true

  # Relationships
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"
  belongs_to :event
  belongs_to :event_user
  has_many :item_users, dependent: :destroy
  accepts_nested_attributes_for :item_users, allow_destroy: true

  # Validations
  validates :payer_id, presence: true
  validates :payee_id, presence: true
  validates :event_id, presence: true
  validates :requested_at, presence: true
  validates :due_at, presence: true
  validates :event_user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :paid?
  validates :processor_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :our_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :transaction_id, presence: true, if: :paid_and_not_cash?

  # Callbacks
  before_validation :copy_event_attributes

  def self.create_or_find_from_event_user(event_user)
    payment_attributes = {
      payer_id: event_user.user.id,
      payee_id: event_user.event.organizer.id,
      event_id: event_user.event.id,
      amount_cents: event_user.event.split_amount_cents
    }
    
    Payment.where(
      payment_attributes
    ).first || create(payment_attributes.merge(
      due_at: event_user.due_at,
      requested_at: event_user.event.created_at,
      event_user_id: event_user.id
    ))
  end

  def paid?
    paid_at.present?
  end

  def total_amount_cents
    (amount_cents || 0) + (processor_fee_amount_cents || 0) + (our_fee_amount_cents || 0)
  end

  def pay!(options={})
    self.transaction_id = options[:transaction_id]
    self.paid_at = Time.now
    self.save
  end

  def unpay!
    self.destroy
  end

  # Handles the entire payment updating process from
  # updating the payment information from the processor
  # to marking the event_user as paid
  def update!
  end

  # Returns truthy value if update works, otherwise falsey
  def update_for_items!
    total_amount_cents = 0
    self.item_users.each do |item_user|
      item = item_user.item
      if item.allow_quantity?
        if item_user.quantity >= item.quantity_min && item_user.quantity <= item.quantity_max
          item_user.total_amount_cents = item.amount_cents * item_user.quantity
        else
          return false
        end
      else
        item_user.total_amount_cents = item.amount_cents
        item_user.quantity = 1
      end
      total_amount_cents += item_user.total_amount_cents
      item_user.save
    end

    if total_amount_cents == 0
      return false
    end

    self.amount_cents = total_amount_cents
    update_fees
    self.save
    self.reload
    true
  end

  # Constants
  class StatusType
    PENDING = 1
    PAID = 2
    CANCELLED = 3
    EXPIRED = 4
  end

private

  def copy_event_attributes
    if self.event.present?
      self.requested_at = self.event.created_at
      self.due_at = self.event.due_at
    end
  end
end