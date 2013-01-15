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
#  start_at           :datetime
#  division_type      :integer
#  fee_type           :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#  organizer_id       :integer
#  privacy_type       :integer
#

class Event < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :amount_cents, :amount, :description, :due_at, :start_at, :title, :division_type, :fee_type, :total_amount_cents, :total_amount, :split_amount_cents, :split_amount, :privacy_type
  monetize :total_amount_cents, allow_nil: true
  monetize :split_amount_cents, allow_nil: true
  monetize :receive_amount_cents, allow_nil: true
  monetize :send_amount_cents, allow_nil: true
  monetize :our_fee_amount_cents, allow_nil: true

  # Validations
  # ========================================================
  validates :organizer_id, presence: true
  validates :division_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }
  validates :fee_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2 }
  validates :privacy_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2 }
  validates :title, presence: true, length: { minimum: 2, maximum: 120 }
  validates :due_at, presence: true
  validates :due_at, date: { after: Proc.new { Time.now } }, if: :due_at_changed?
  validates :start_at, presence: true
  validates :start_at, date: { after: Proc.new { Time.now } }, if: :start_at_changed?
  validates :total_amount, presence: true, numericality: { greater_than: 0 }, if: :divide_total?
  validates :split_amount, presence: true, numericality: { greater_than: 0 }, if: :divide_per_person?

  # Relationships
  # ========================================================
  belongs_to :organizer, class_name: "User"
  has_many :event_users, dependent: :destroy
  has_many :members, class_name: "User", through: :event_users, source: :member, select: "users.*, event_users.amount_cents, event_users.due_at, event_users.paid_at"
  has_many :messages, dependent: :destroy
  has_many :event_groups, dependent: :destroy
  has_many :groups, through: :event_groups, source: :group

  # Callbacks
  # ========================================================
  before_validation :clear_amounts

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

  # Dates
  # ========================================================

  def due_at_date
    if due_at.present?
      due_at.to_date.to_s
    end
  end

  def due_at_time
    if due_at.present?
      due_at.strftime('%I:%M%p')
    end
  end

  # Member definitions
  # ========================================================
  def paying_members
    self.members - [self.organizer]
  end
  
  def add_member(member)
    add_members([member])
  end

  def add_members(members, exclude_from_notifications=nil)
    editing_event = true if self.members.length != 0
    members.each do |member|
      if member.valid?
        if self.members.include?(member)
          Notification.create_or_update_for_event_update(self, member) if member != exclude_from_notifications
        else
          self.members << member 
          Notification.create_for_event(self, member) if member != exclude_from_notifications
          if editing_event
            NewsItem.create_for_new_event_member(self, member)
          end
        end
      end
    end

    delay.send_invitation_emails
    set_event_user_attributes(exclude_from_notifications)
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

  def add_groups(groups)
    groups.each do |group|
      self.groups << group unless self.groups.include?(group)
    end
  end

  # This method is awesome
  def independent_members
    nfgdi_members = self.members

    self.groups.each do |group|
      nfgdi_members -= group.members
    end

    nfgdi_members
  end

  def to_param
    "#{id}-#{title}".parameterize
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

end
