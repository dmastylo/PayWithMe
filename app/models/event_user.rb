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

  # Relationships
  belongs_to :member, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_one :payment

  monetize :amount_cents

  def paid?
  	paid_at.present?
  end

  def visit_event!
    if !visited_event?
      toggle(:visited_event).save
    end
  end
  
end
