# == Schema Information
#
# Table name: event_users
#
#  id                           :integer          not null, primary key
#  event_id                     :integer
#  user_id                      :integer
#  amount_cents                 :integer          default(0)
#  due_at                       :datetime
#  paid_at                      :datetime
#  sent_invitation_email        :boolean          default(FALSE)
#  visited_event                :boolean          default(FALSE)
#  last_seen                    :datetime
#  paid_with_cash               :boolean          default(TRUE)
#  paid_total_cents             :integer          default(0)
#  status                       :integer          default(0)
#  nudges_remaining             :integer          default(0)
#  sent_ticket_email            :boolean          default(FALSE)
#  sent_invitation_notification :boolean          default(FALSE)
#  sent_guest_broadcast         :boolean          default(FALSE)
#  invitation_group             :integer          default(0)
#

class EventUser < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :event_id, :user_id
  monetize :amount_cents, allow_nil: true
  monetize :paid_total_cents, allow_nil: true

  # Validations
  validates :event_id, presence: true
  validates :user_id, presence: true

  # Relationships
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_one :payment
  has_many :nudges
  has_many :item_users

  # Callbacks
  after_create :check_event
  after_create :update_payment!
  before_save :set_status

  def paid?
    status == Status::PAID
  end

  def unpaid?
    paid_at.nil?
  end

  def on_page?
    self.last_seen.present? && self.last_seen > 1.minute.ago
  end

  def visit_event!
    if !visited_event?
      toggle(:visited_event).save
    end
  end

  def is_member?
    self.event.present? && self.event.organizer != self.user
  end

  def is_organizer?
    self.event.present? && self.event.organizer == self.user
  end

  class Status
    UNPAID = 0
    PENDING = 1
    PAID = 2
  end

  def update_nudges_remaining
    if self.paid?
      self.nudges_remaining = Figaro.env.nudge_limit.to_i - Nudge.where(
        nudger_id: self.user_id, event_id: self.event_id).count
    else
      self.nudges_remaining = 0
    end
  end

  # Ensures that all payment information is updated
  # :remote specifies to update payment information from Balanced
  def update_payment!(options={ remote: false })
    attributes = { payer_id: self.user_id, payee_id: self.event.organizer_id, event_id: self.event_id, amount: self.amount }
    unless self.payment.present?
      self.build_payment(attributes, without_protection: true).save
    else
      self.payment.update_attributes!(attributes, without_protection: true)
    end
    if options[:remote]

    end
  end

  def set_status!
    set_status
    self.save
  end

  def set_status
    if payment.present? && payment.paid?
      self.status = Status::PAID
      self.paid_at = payment.paid_at
    else
      self.status = Status::UNPAID
      self.paid_at = nil
    end
  end

# private
  # TODO: This seems like a common pattern that we need
  def check_event!
    check_event
    save
  end

  def check_event
    self.due_at = self.event.due_at
    unless self.event.not_using_total?
      self.amount_cents = self.event.per_person_cents
    end
  end

  def send_nudges
    if self.paid?
      Nudge.where(event_id: self.event_id, nudger_id: self.user_id).each do |nudge|
        nudge.send_nudge_email_if_paid
      end
    end
  end

end
