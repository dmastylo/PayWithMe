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
#

class Event < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :amount_cents, :amount, :description, :due_on, :start_at, :title, :division_type, :fee_type, :total_amount_cents, :total_amount, :split_amount_cents, :split_amount
  monetize :total_amount_cents, allow_nil: true
  monetize :split_amount_cents, allow_nil: true
  monetize :receive_amount_cents, allow_nil: true
  monetize :send_amount_cents, allow_nil: true

  # Relationships
  belongs_to :organizer, class_name: "User"

  def receive_amount_cents
  end

  def send_amount_cents
  end

  # Constants
  class DivisionType
    Total = 0
    Split = 1
    Fundraise = 2
  end
  class FeeType
    OrganizerPay = 0
    MembersPay = 1
  end

end
