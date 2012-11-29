# == Schema Information
#
# Table name: event_users
#
#  id           :integer          not null, primary key
#  event_id     :integer
#  user_id      :integer
#  amount_cents :integer          default(0)
#  due_date     :date
#  paid_date    :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class EventUser < ActiveRecord::Base
  attr_accessible :amount, :due_date, :event_id, :paid_date, :user_id
end
