# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  due_at             :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  division_type      :integer
#  fee_type           :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#  organizer_id       :integer
#  privacy_type       :integer
#  slug               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_url          :string(255)
#

class Event < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :amount_cents, :amount, :description, :due_at, :title, :division_type, :fee_type, :total_amount_cents, :total_amount, :split_amount_cents, :split_amount, :privacy_type, :due_at_date, :due_at_time, :image, :image_type, :image_url, :payment_methods_raw
  attr_accessor :due_at_date, :due_at_time, :image_type, :payment_methods_raw
  monetize :total_amount_cents, allow_nil: true
  monetize :split_amount_cents, allow_nil: true
  monetize :receive_amount_cents, allow_nil: true
  monetize :send_amount_cents, allow_nil: true
  monetize :our_fee_amount_cents, allow_nil: true
  monetize :money_collected_cents, allow_nil: true
  has_attached_file :image

  # Validations
  # ========================================================
  validates :organizer_id, presence: true
  validates :division_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3, message: "is an invalid division type" }
  validates :fee_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2, message: "is an invalid fee type" }
  validates :privacy_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2, message: "is an invalid privacy type" }
  validates :title, presence: true, length: { minimum: 2, maximum: 120, message: "has to be between 2 and 120 characters long" }
  validates :due_at, presence: true
  validates :due_at, date: { after: Proc.new { Time.now }, message: "can't be in the past" }, if: :due_at_changed?
  validates :total_amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :divide_total?
  validates :split_amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :divide_per_person?
  validate :amounts_not_changed, on: :update, if: :received_money?

  # Relationships
  # ========================================================
  belongs_to :organizer, class_name: "User"
  has_many :event_users, dependent: :destroy
  has_many :members, class_name: "User", through: :event_users, source: :member
  has_many :messages, dependent: :destroy
  has_many :event_groups, dependent: :destroy
  has_many :groups, through: :event_groups, source: :group
  has_many :reminders, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :nudges

  # Callbacks
  # ========================================================
  before_validation :clear_amounts
  before_validation :concatenate_dates
  before_validation :parse_payment_methods
  before_save :clear_dates
  before_save :set_event_image
  before_save :add_organizer_to_members
  before_destroy :clear_notifications_and_news_items
  after_save :create_payment_methods

  # Pretty URLs
  # ========================================================
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # Money definitions
  # ========================================================
  def receive_amount_cents
    if division_type == DivisionType::Fundraise || paying_members.size == 0 || send_amount_cents.nil?
      nil
    elsif fee_type == FeeType::OrganizerPays
      (paying_members.size * (send_amount_cents * (1 - Figaro.env.fee_rate.to_f) - Figaro.env.fee_static.to_f * 100.0)).floor
    else
      split_amount_cents
    end
  end

  def send_amount_cents
    if division_type == DivisionType::Fundraise || paying_members.size == 0 || split_amount_cents.nil?
      nil
    elsif fee_type == FeeType::OrganizerPays
      split_amount_cents
    else
      ((split_amount_cents + Figaro.env.fee_static.to_f * 100.0) / (1.0 - Figaro.env.fee_rate.to_f)).ceil
    end
  end

  def total_amount_cents
    if division_type == DivisionType::Total
      super
    elsif paying_members.size == 0 || division_type == DivisionType::Fundraise || division_type.nil? || split_amount_cents.nil?
      nil
    else
      split_amount_cents * paying_members.size
    end
  end

  def split_amount_cents
    if division_type == DivisionType::Split
      super
    elsif paying_members.size == 0 || division_type.nil? || division_type == DivisionType::Fundraise
      nil
    else
      total_amount_cents / paying_members.size
    end
  end

  def our_fee_amount_cents
    if send_amount_cents.present?
      (send_amount_cents * (Figaro.env.fee_rate.to_f - Figaro.env.paypal_fee_rate.to_f) - (Figaro.env.fee_static.to_f - Figaro.env.paypal_fee_static.to_f) * 100.0).floor
    else
      nil
    end
  end
  
  def money_collected_cents
    if split_amount_cents.present?
      split_amount_cents * paid_members.count
    end
  end

  # Division types
  # ========================================================
  def divide_total?
    division_type == DivisionType::Total
  end

  def divide_per_person?
    division_type == DivisionType::Split
  end

  def fundraiser?
    division_type == DivisionType::Fundraise
  end

  # Fee types
  # ========================================================
  def organizer_pays?
    fee_type == FeeType::OrganizerPays
  end

  def members_pay?
    fee_type == FeeType::MembersPay
  end

  # Privacy types
  def public?
    privacy_type == PrivacyType::Public
  end

  def private?
    privacy_type == PrivacyType::Private
  end

  # Payment methods
  # ========================================================

  def accepts_payment_method?(payment_method)
    self.payment_methods.where(payment_method: payment_method).count > 0
  end

  def send_with_payment_method?(payment_method)
    return true
    return false unless accepts_payment_method?(payment_method)

    if payment_method == PaymentMethod::MethodType::CASH
      true
    elsif payment_method == PaymentMethod::MethodType::PAYPAL
      self.organizer.paypal_account.present?
    elsif payment_method == PaymentMethod::MethodType::DWOLLA
      self.organizer.dwolla_account.present?
    end
  end

  def accepts_cash?
    accepts_payment_method?(PaymentMethod::MethodType::CASH)
  end
  alias_method :send_cash?, :accepts_cash?

  def accepts_paypal?
    accepts_payment_method?(PaymentMethod::MethodType::PAYPAL)
  end

  def send_with_paypal?
    send_with_payment_method?(PaymentMethod::MethodType::PAYPAL)
  end

  def accepts_dwolla?
    accepts_payment_method?(PaymentMethod::MethodType::DWOLLA)
  end

  def send_with_dwolla?
    send_with_payment_method?(PaymentMethod::MethodType::DWOLLA)
  end

  # Mostly used in testing
  def mark_paid(user)
    event_user = event_user(user)
    event_user.paid_at = Time.now
    event_user.save
  end

  # Constants
  # ========================================================
  class DivisionType
    Total = 1
    Split = 2
    Fundraise = 3
  end
  class FeeType
    OrganizerPays = 1
    MembersPay = 2
  end
  class PrivacyType
    Public = 1
    Private = 2
  end

  # Virtual attributes
  # ========================================================
  def due_at_date
    if @due_at_date.present?
      @due_at_date
    elsif due_at.present?
      due_at.to_date.to_s
    end
  end

  def due_at_time
    if @due_at_time.present?
      @due_at_time
    elsif due_at.present?
      due_at.strftime('%I:%M%p')
    end
  end

  # Event image
  # ========================================================
  def image_type
    if @image_type.present?
      @image_type
    elsif image.present?
      :upload
    elsif image_url.present?
      :url
    else
      :default_image
    end
  end

  def payment_methods_raw
    if @payment_methods_raw.present?
      @payment_methods_raw
    else
      payment_methods_raw = []
      payment_methods.each do |payment_method|
        payment_methods_raw << payment_method.payment_method
      end
      payment_methods_raw
    end
  end

  # Member definitions
  # ========================================================
  def paying_members
    self.members - [self.organizer]
  end

  def paid_members
    paid_event_users = event_users.where("paid_at IS NOT NULL")
    users = paid_event_users.collect { |event_user| event_user.member }
  end

  def unpaid_members
    unpaid_event_users = event_users.where("paid_at IS NULL")
    users = unpaid_event_users.collect { |event_user| event_user.member }
  end

  def paid_percentage
    if paying_members.count > 0
      (paid_members.count * 100.0) / paying_members.count 
    else
      0
    end
  end
  
  def add_member(member)
    add_members([member])
  end

  def add_members(members_to_add, exclude_from_notifications=nil)
    editing_event = true if self.members.length != 0
    members_to_add.each do |member|
      if member.valid?
        if self.members.include?(member)
          Notification.create_or_update_for_event_update(self, member) if member != exclude_from_notifications
        else
          self.members << member 
          Notification.create_for_event(self, member) if member != exclude_from_notifications
          if editing_event
            NewsItem.delay.create_for_new_event_member(self, member)
          end
        end
      end
    end

    delay.send_invitation_emails
    set_event_user_attributes(exclude_from_notifications)
  end

  # Adds members and deletes any not in the set
  def set_members(members_to_set, exclude_from_notifications=nil)
    members_to_delete = []
    self.members.each do |member|
      if !members_to_set.include?(member)
        members_to_delete.push member
      end
    end
    self.members -= members_to_delete

    add_members(members_to_set, exclude_from_notifications)
  end

  def remove_members(members_to_remove)
    set_members(self.members - members_to_remove)
  end

  def remove_member(member_to_remove)
    remove_members([member_to_remove])
  end

  def set_event_user_attributes(exclude_from_notifications)
    self.event_users.each do |event_user|
      if event_user.member != exclude_from_notifications
        event_user.due_at = self.due_at
        event_user.amount_cents = self.send_amount_cents
        event_user.save
      end
    end
  end

  def send_invitation_emails
    self.event_users.each do |event_user|
      if !event_user.invitation_sent? && event_user.member != self.organizer
        UserMailer.event_notification(event_user.member, self).deliver
        event_user.toggle(:invitation_sent).save
      end
    end
  end

  def send_message_notifications
    self.members.each do |member|
      Notification.create_or_update_for_event_message(self, member)    
    end
  end

  def add_groups(groups_to_add)
    groups_to_add.each do |group|
      self.groups << group unless self.groups.include?(group)
    end
  end

  def set_groups(groups_to_set)
    self.groups.each do |group|
      if !groups_to_set.include?(group)
        self.groups.delete(group)
      end
    end

    add_groups(groups_to_set)
  end

  def remove_groups(groups_to_remove)
    self.set_groups(self.groups - groups_to_remove)
  end

  def remove_group(group_to_remove)
    self.remove_groups([group_to_remove])
  end

  # This method is awesome
  def independent_members
    nfgdi_members = self.paying_members

    self.groups.each do |group|
      nfgdi_members -= group.members
    end

    nfgdi_members
  end

  def invited?(user)
    members.include?(user)
  end

  def event_user(user)
    event_users.find_by_user_id(user)
  end

  def paid?(user)
    event_user = event_user(user)
    event_user.present? && event_user.paid?
  end

  def paid_at(user)
    event_user(user).paid_at
  end

  def received_money?
    paid_members.count > 0
  end

  # Nudges
  def can_nudge?(nudger, nudgee)
    if !invited?(nudger) ||
      !invited?(nudgee) ||
      paid_at(nudger).nil? ||
      paid_at(nudgee).present? ||
      nudgee == self.organizer ||
      nudger.stub? ||
      nudger.sent_nudges.find_all_by_event_id(self.id).count >= Figaro.env.nudge_limit.to_i ||
      self.nudges.where(nudgee_id: nudgee.id, nudger_id: nudger.id).count > 0
      false
    else
      true
    end
  end

  def nudge!(nudger, nudgee)
    if can_nudge?(nudger, nudgee)
      nudges.create!(nudger_id: nudger.id, nudgee_id: nudgee.id)
    end
  end

private
  def clear_amounts
    if division_type != DivisionType::Split
      split_amount_cents = nil
      split_amount = nil
    end

    if division_type != DivisionType::Total
      total_amount_cents = nil
      total_amount = nil
    end
  end

  def concatenate_dates
    self.due_at = "#{self.due_at_date} #{self.due_at_time}"
  end

  def parse_payment_methods
    if !self.payment_methods_raw.is_a?(Array)
      self.payment_methods_raw = ActiveSupport::JSON.decode(self.payment_methods_raw).uniq
    end
  end

  def create_payment_methods
    self.payment_methods.destroy_all

    self.payment_methods_raw.each do |payment_method|
      self.payment_methods.create(payment_method: payment_method)
    end
  end

  def clear_dates
    due_at_date = due_at_time = nil
  end

  def set_event_image
    return unless self.image_type.present?

    if self.image_type != "url"
      self.image_url = nil
    end

    if self.image_type != "upload"
      self.image = nil
    end

    image_type = nil
  end
  
  def add_organizer_to_members
    if !members.include?(organizer)
      members << organizer
    end
  end

  def amounts_not_changed
    if divide_total? && total_amount_cents_changed?
      errors.add(:total_amount, "cannot be changed after a member has paid")
    end

    if divide_per_person? && split_amount_cents_changed?
      errors.add(:split_amount, "cannot be changed after a member has paid")
    end
  end
  
  def clear_notifications_and_news_items
    Notification.where(foreign_id: self.id, foreign_type: Notification::ForeignType::EVENT).destroy_all
    NewsItem.where(foreign_id: self.id, foreign_type: NewsItem::ForeignType::EVENT).destroy_all
  end

end
