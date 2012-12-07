# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  due_at             :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  start_at           :datetime
#  division_type      :integer
#  fee_type           :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#  organizer_id       :integer
#

class Event < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :amount_cents, :amount, :description, :due_at, :start_at, :title, :division_type, :fee_type, :total_amount_cents, :total_amount, :split_amount_cents, :split_amount, :groups
  attr_accessor :groups
  monetize :total_amount_cents, allow_nil: true
  monetize :split_amount_cents, allow_nil: true
  monetize :receive_amount_cents, allow_nil: true
  monetize :send_amount_cents, allow_nil: true

  # Validations
  validates :organizer_id, presence: true
  validates :division_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }
  validates :fee_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2 }
  validates :title, presence: true, length: { minimum: 2, maximum: 120 }
  validates :due_at, presence: true
  validates :due_at, date: { after: Proc.new { Time.now } }, if: :due_at_changed?
  validates :start_at, presence: true
  validates :start_at, date: { after: Proc.new { Time.now } }, if: :start_at_changed?
  validates :total_amount, presence: true, numericality: { greater_than: 0 }, if: :divide_total?
  validates :split_amount, presence: true, numericality: { greater_than: 0 }, if: :divide_per_person?

  # Relationships
  belongs_to :organizer, class_name: "User"
  has_many :event_users, dependent: :destroy
  has_many :members, class_name: "User", through: :event_users, source: :member, select: "users.*, event_users.amount_cents, event_users.due_date, event_users.paid_date"
  has_many :messages, dependent: :destroy
  has_many :event_groups, dependent: :destroy
  has_many :groups, through: :event_groups

  # Callbacks
  before_validation :clear_amounts

  # Money definitions
  def receive_amount_cents
    if division_type == DivisionType::Fundraise || members.size == 0 || send_amount_cents.nil?
      nil
    elsif fee_type == FeeType::OrganizerPays
      members.size * (send_amount_cents * (1 - Figaro.env.fee_rate.to_f) - Figaro.env.fee_static.to_f * 100.0)
    else
      total_amount_cents
    end
  end

  def send_amount_cents
    if division_type == DivisionType::Fundraise || members.size == 0 || split_amount_cents.nil?
      nil
    elsif fee_type == FeeType::OrganizerPays
      split_amount_cents
    else
      ((split_amount_cents + Figaro.env.fee_static.to_f * 100.0) / (1.0 - Figaro.env.fee_rate.to_f)).ceil
    end
  end

  def total_amount_cents
    if super || division_type == DivisionType::Total
      super
    elsif members.size == 0 || division_type == DivisionType::Fundraise || split_amount_cents.nil? || super.nil?
      nil
    else
      split_amount_cents * members.size
    end
  end

  def split_amount_cents
    if super || division_type == DivisionType::Split
      super
    elsif members.size == 0 || division_type == DivisionType::Fundraise  || super.nil?
      nil
    else
      total_amount_cents / members.size
    end
  end

  # Division types
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
  def organizer_pays?
    fee_type == FeeType::OrganizerPays
  end

  def members_pay?
    fee_type == FeeType::MembersPay
  end

  # Constants
  class DivisionType
    Total = 1
    Split = 2
    Fundraise = 3
  end
  class FeeType
    OrganizerPays = 1
    MembersPay = 2
  end

  def add_members(members, exclude=nil)
    members.each do |member|
      self.members << member unless self.members.include?(member)
    end

    self.event_users.each do |event_user|
      if event_user.member != exclude
        event_user.due_date = self.due_at
        event_user.amount_cents = self.send_amount_cents
        event_user.save
      end
    end
  end

  def add_groups(groups)
    groups.each do |group|
      self.groups << group unless self.groups.include?(group)
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

end
