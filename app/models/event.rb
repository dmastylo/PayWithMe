class Event < ActiveRecord::Base
  attr_accessible :amount, :description, :due_date, :title
end
