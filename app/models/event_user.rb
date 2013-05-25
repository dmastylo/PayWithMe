# == Schema Information
#
# Table name: event_users
#
#  id               :integer          not null, primary key
#  event_id         :integer
#  user_id          :integer
#  amount_cents     :integer          default(0)
#  due_at           :datetime
#  paid_at          :datetime
#  invitation_sent  :boolean          default(FALSE)
#  payment_id       :integer
#  visited_event    :boolean          default(FALSE)
#  last_seen        :datetime
#  paid_with_cash   :boolean          default(TRUE)
#  paid_total_cents :integer          default(0)
#  status           :integer          default(0)
#  nudges_remaining :integer          default(0)
#  accepted_invite  :boolean          default(FALSE)
#

class EventUser < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :event_id, :user_id
  monetize :amount_cents, allow_nil: true
  monetize :paid_total_cents, allow_nil: true

  # Validations
  validates :event_id, presence: true
  validates :user_id, presence: true
  # validates :amount_cents, presence: true

  # Relationships
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_many :payments
  has_many :nudges
  has_many :item_users

  # Callbacks
  # before_validation :copy_event_attributes
  # after_initialize :copy_event_attributes
  # after_save :copy_event_attributes

  def paid?
  	paid_at.present?
  end

  def on_page?
    self.last_seen.present? && self.last_seen > 1.minute.ago
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

  # def paid_total_cents
  #   payments.where("paid_at IS NOT NULL").sum(&:amount_cents)
  # end

  def create_payment(options={})
    copy_event_attributes
    current_cents = options[:amount_cents] || amount_cents
    payment_method = PaymentMethod.find_by_id(options[:payment_method] || PaymentMethod::MethodType::CASH)
    unless self.event.fundraiser? || self.event.itemized?
      if current_cents > amount_cents
        return false
      end
    end

    payment = user.sent_payments.find_or_create_by_payee_id_and_event_id_and_event_user_id_and_amount_cents_and_payment_method_id_and_paid_at(
      payee_id: event.organizer.id,
      event_id: event.id,
      event_user_id: self.id,
      amount_cents: current_cents,
      payment_method_id: payment_method.id,
      paid_at: nil
    )

    if self.event.itemized?
      self.event.items.each do |item|
        payment.item_users.find_or_create_by_event_id_and_event_user_id_and_item_id_and_user_id(event_id: payment.event_id, event_user_id: payment.event_user_id, item_id: item.id, user_id: payment.event_user.user_id)
      end
    end
    payment
  end

  def pay!(payment, options={})
    copy_event_attributes
    payment.pay!(options)

    update_paid_total_cents
    update_paid_with_cash
    update_status
    send_nudges
    update_nudges_remaining
    self.save
    true
  end

  # def paid_with_cash?
  #   self.payments.where('payment_method_id != ?', PaymentMethod::MethodType::CASH).count > 0
  # end
  
  def unpay_cash_payments!
    copy_event_attributes
    self.payments.where(payment_method_id: PaymentMethod::MethodType::CASH).destroy_all

    update_paid_total_cents
    update_paid_with_cash
    update_status
    self.save
  end

  def unpay!(payment)
    copy_event_attributes
    payment.unpay!

    update_paid_total_cents
    update_paid_with_cash
    update_status
    update_nudges_remaining
    self.save
  end

  # Deletes all unfinished payments except for keep_payment
  def clean_up_payments!(keep_payment_id=nil)
    self.payments.each do |payment|
      if payment.id != keep_payment_id && payment.paid_at.nil?
        payment.destroy
      end
    end
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

    self.save
  end

  def update_status
    statuses = self.payments.collect(&:status).uniq

    if statuses.include?("new") && paid_at.nil?
      self.status = EventUser::Status::PENDING
    elsif paid_at.present?
      self.status = EventUser::Status::PAID
      clean_up_payments!
    else
      self.status = EventUser::Status::UNPAID
    end
  end

private
  def copy_event_attributes
    if self.event.present? && self.member?
      self.due_at = self.event.due_at
    end
    unless self.event.fundraiser? || self.event.itemized?
      self.amount_cents = self.event.split_amount_cents
    end
  end

  def update_paid_with_cash
    self.paid_with_cash = true
    self.payments.each do |payment|
      self.paid_with_cash = false unless payment.payment_method_id == PaymentMethod::MethodType::CASH || payment.paid_at.nil?
    end
  end

  def update_paid_total_cents
    self.paid_total_cents = 0
    self.payments.each do |payment|
      self.paid_total_cents += payment.amount_cents if payment.paid_at.present?
    end

    if self.paid_total_cents >= self.amount_cents
      self.paid_at = Time.now
    else
      self.paid_at = nil
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
