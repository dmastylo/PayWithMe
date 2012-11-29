# == Schema Information
#
# Table name: event_settings
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventSetting < ActiveRecord::Base
  attr_accessible :event_id
end
