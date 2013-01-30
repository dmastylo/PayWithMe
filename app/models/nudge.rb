class Nudge < ActiveRecord::Base
  attr_accessible :event_id, :event_user_id, :nudgee_id, :nudger_id
end
