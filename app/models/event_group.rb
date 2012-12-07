class EventGroup < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :event_id, :group_id

  # Relationships
  belongs_to :event
  belongs_to :group

end