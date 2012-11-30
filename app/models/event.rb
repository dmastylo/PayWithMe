# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  due_on             :date
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
  attr_accessible :amount_cents, :amount, :description, :due_at, :start_at, :title, :division_type, :fee_type, :total_amount_cents, :total_amount, :split_amount_cents, :split_amount
  monetize :total_amount_cents, allow_nil: true
  monetize :split_amount_cents, allow_nil: true
  monetize :receive_amount_cents, allow_nil: true
  monetize :send_amount_cents, allow_nil: true

  # Validations
  validates :organizer_id, presence: true
  validates :division_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }
  validates :fee_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2 }
  validates :title, presence: true, length: { minimum: 2 }
  validates :due_at, presence: true
  validates :due_at, date: { after: Proc.new { Time.now } }, if: :due_at_changed?
  # validates :start_at, presence: true
  # validates :start_at, date: { after: Proc.new { Time.now } }, if: :start_at_changed?
  # validates :total_amount, presence: true if (division_type == Event::DivisionType::Total)

  # Relationships
  belongs_to :organizer, class_name: "User"
  has_and_belongs_to_many :members, class_name: "User", join_table: "event_users"

  # Callbacks
  before_validation :clear_amounts

  def receive_amount_cents
    if division_type == DivisionType::Fundraise || members.size == 0
      nil
    elsif fee_type == FeeType::OrganizerPay
      members.size * (send_amount_cents * (1 - Figaro.env.fee_rate.to_f) - Figaro.env.fee_static.to_f)
    else
      total_amount_cents
    end
  end

  def send_amount_cents
    if division_type == DivisionType::Fundraise || members.size == 0
      nil
    elsif fee_type == FeeType::OrganizerPay
      split_amount_cents
    else
      (total_amount_cents / members.size + Figaro.env.fee_static.to_f) / (1 - Figaro.env.fee_rate.to_f)
    end
  end

  def total_amount_cents
    if super
      super
    else
      if members.size == 0 || division_type == DivisionType::Fundraise
        nil
      else
        split_amount_cents * members.size
      end
    end
  end

  def split_amount_cents
    if super
      super
    else
      if members.size == 0 || division_type == DivisionType::Fundraise
        nil
      else
        total_amount_cents / members.size
      end
    end
  end

  # Constants
  class DivisionType
    Total = 1
    Split = 2
    Fundraise = 3
  end
  class FeeType
    OrganizerPay = 1
    MembersPay = 2
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
