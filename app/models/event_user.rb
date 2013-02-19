# == Schema Information
#
# Table name: event_users
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  user_id         :integer
#  amount_cents    :integer          default(0)
#  due_at          :datetime
#  paid_at         :datetime
#  invitation_sent :boolean          default(FALSE)
#  payment_id      :integer
#  visited_event   :boolean          default(FALSE)
#

class EventUser < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :event_id, :user_id
  monetize :amount_cents, allow_nil: true

  # Validations
  validates :event_id, presence: true
  validates :user_id, presence: true
  validates :amount_cents, presence: true

  # Relationships
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_many :payments
  has_many :nudges

  # Validations
  validates :due_at, presence: true, if: :member?
  validates :user_id, presence: true
  validates :event_id, presence: true

  # Callbacks
  before_validation :copy_event_attributes
  after_initialize :copy_event_attributes
  after_save :copy_event_attributes

  def paid?
  	paid_at.present?
  end

  def visit_event!
    if !visited_event?
      toggle(:visited_event).save
    end
  end

  def amount_present?
    self.amount.present?
  end

  def member?
    self.event.present? && self.event.organizer != self.user
  end

  def organizer?
    self.event.present? && self.event.organizer == self.user
  end

  def paid_total_cents
    payments.where("paid_at IS NOT NULL").sum(&:amount_cents)
  end

  def create_payment(options={})
    current_cents = options[:amount_cents] || amount_cents
    payment_method = PaymentMethod.find_by_id(options[:payment_method] || PaymentMethod::MethodType::CASH)
    if current_cents > amount_cents
      return false
    end

    payment = user.sent_payments.find_or_create_by_payee_id_and_event_id_and_event_user_id_and_amount_cents_and_payment_method_id_and_paid_at(
      payee_id: event.organizer.id,
      event_id: event.id,
      event_user_id: self.id,
      amount_cents: current_cents,
      payment_method_id: payment_method.id,
      paid_at: nil
    )
  end

  def pay!(payment, options={})
    payment.pay!(options)

    if self.paid_total_cents >= self.amount_cents
      self.paid_at = Time.now
      save
    end
    true
  end

private
  def copy_event_attributes
    if self.event.present? && self.member?
      self.due_at = self.event.due_at
      self.amount_cents = self.event.split_amount_cents
    end
  end
  
end
