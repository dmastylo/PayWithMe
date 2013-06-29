# == Schema Information
#
# Table name: payments
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  paid_at             :datetime
#  payer_id            :integer
#  payee_id            :integer
#  event_id            :integer
#  amount_cents        :integer
#  event_user_id       :integer
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
  belongs_to :payee, class_name: "User"
  belongs_to :event
  belongs_to :event_user
  has_many :item_users, dependent: :destroy
  accepts_nested_attributes_for :item_users, allow_destroy: true

  # Validations
  validates :payer_id, presence: true
  validates :payee_id, presence: true
  validates :event_id, presence: true
  validates :event_user_id, presence: true
  validates_with PaymentAmountValidator

  # Callbacks
  before_save :set_status

  # TODO: Box this validation up somewhere else and make it simpler here
  # validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :paid?
  # validates :processor_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :our_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # validates :transaction_id, presence: true, if: :paid_and_not_cash?

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
    if cash? && paid_amount.present?
      if paid_amount == amount && !paid?
        self.paid_at = Time.now
      elsif paid_amount < amount && paid?
        self.paid_at = nil
      end
    end
  end

  # def self.find_or_create_from_event_user(event_user, options={})
  #   payment_attributes = {
  #     payer_id: event_user.user.id,
  #     payee_id: event_user.event.organizer.id,
  #     event_id: event_user.event.id,
  #     amount_cents: event_user.event.per_person_cents
  #   }
  #   payment_attributes[:cash] = options[:cash].present? && options[:cash]
    
  #   Payment.where(payment_attributes).first || create(payment_attributes.merge(
  #     due_at: event_user.due_at,
  #     requested_at: event_user.event.created_at,
  #     event_user_id: event_user.id
  #   ))
  # end

  def paid?
    paid_at.present?
  end

  def unpaid?
    !paid?
  end

  def pay!
    self.payer.account.debit(self.amount)
  end

  # def total_cents
  #   (amount_cents || 0) + (processor_fee_cents || 0) + (our_fee_cents || 0)
  # end

  # def pay!(options={})
  #   self.transaction_id = options[:transaction_id]
  #   self.paid_at = Time.now
  #   self.save
  # end

  # def unpay!
  #   self.destroy
  # end

  # # Handles the entire payment updating process from
  # # updating the payment information from the processor
  # # to marking the event_user as paid
  # def update!
  # end

  # # Returns truthy value if update works, otherwise falsey
  # def update_for_items!
  #   # TODO: Completely rewrite this
  #   total_cents = 0
  #   self.item_users.each do |item_user|
  #     item = item_user.item
  #     if item.allow_quantity?
  #       if item_user.quantity >= item.quantity_min && item_user.quantity <= item.quantity_max
  #         item_user.total_cents = item.amount_cents * item_user.quantity
  #       else
  #         return false
  #       end
  #     else
  #       item_user.total_cents = item.amount_cents
  #       item_user.quantity = 1
  #     end
  #     total_cents += item_user.total_cents
  #     item_user.save
  #   end

  #   if total_cents == 0
  #     return false
  #   end

  #   self.amount_cents = total_cents
  #   update_fees
  #   self.save
  #   self.reload
  #   true
  # end

  # # Constants
  # class Status
  #   # TODO: Model this off of Balanced
  # end

private

  def copy_event_attributes
    if self.event.present?
      self.requested_at = self.event.created_at
      self.due_at = self.event.due_at
    end
  end
end
