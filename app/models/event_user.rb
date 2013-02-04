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
  attr_accessible :amount, :due_at, :event_id, :paid_at, :user_id
  monetize :amount_cents, allow_nil: true

  # Relationships
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_many :payments

  # Validations
  validates :due_at, presence: true, if: :member?
  validates :user_id, presence: true
  validates :event_id, presence: true
  # validates :amount, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :amount_present?

  # Callbacks
  before_validation :copy_event_attributes

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

private
  def copy_event_attributes
    if self.event.present? && self.member?
      self.due_at = self.event.due_at
      self.amount_cents = self.event.split_amount_cents
    end
  end
  
end