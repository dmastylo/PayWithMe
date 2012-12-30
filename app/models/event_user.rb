# == Schema Information
#
# Table name: event_users
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  user_id         :integer
#  amount_cents    :integer          default(0)
#  due_date        :date
#  paid_date       :date
#  invitation_sent :boolean          default(FALSE)
#

class EventUser < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :amount, :due_date, :event_id, :paid_date, :user_id

  # Relationships
  belongs_to :member, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  
end
