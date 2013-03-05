# == Schema Information
#
# Table name: nudges
#
#  id         :integer          not null, primary key
#  nudgee_id  :integer
#  nudger_id  :integer
#  event_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Nudge < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :event_id, :nudgee_id, :nudger_id

  # Validations
  validates :event_id, presence: true
  validates :nudgee_id, presence: true
  validates :nudger_id, presence: true

  # Associations
  belongs_to :nudgee, class_name: "User"
  belongs_to :nudger, class_name: "User"
  belongs_to :event

  # Callbacks
  after_create :send_nudge_email

private
  # Two methods to keep the delayed_job job clean and without extra information
  def send_nudge_email
    Nudge.delay.send_nudge_email(self.id)
  end

  def self.send_nudge_email(nudge_id)
    nudge = Nudge.find(nudge_id)
    UserMailer.nudge_notification(nudge.nudgee, nudge).deliver
  end

end
