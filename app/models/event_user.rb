class EventUser < ActiveRecord::Base
  attr_accessible :amount, :due_date, :event_id, :paid_date, :user_id
end
