# == Schema Information
#
# Table name: event_groups
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  group_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventGroup < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :event_id, :group_id

  # Relationships
  belongs_to :event
  belongs_to :group

end