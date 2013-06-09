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
#  sent_at    :datetime
#  rating     :integer
#

class Nudge < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :event_id, :nudgee_id, :nudger_id, :rating

  # Validations
  # ========================================================
  validates :event_id, presence: true
  validates :nudgee_id, presence: true
  validates :nudger_id, presence: true

  # Associations
  # ========================================================
  belongs_to :nudgee, class_name: "User"
  belongs_to :nudger, class_name: "User"
  belongs_to :event

  # Callbacks
  # ========================================================
  after_create :send_nudge_email_if_paid

  # Scopes
  # ========================================================
  def self.nudges_rated_G
    Nudge.where(rating: 1)
  end

  def self.nudges_rated_PG13
    Nudge.where(rating: 2)
  end

  def self.nudges_rated_R
    Nudge.where(rating: 3)
  end

  def send_nudge_email_if_paid
    if self.event.event_user(self.nudger).status == EventUser::Status::PAID
      send_nudge_email
    end
  end

  def G?
    rating == Rating::G
  end

  def PG13?
    rating == Rating::PG13
  end

  def R?
    rating == Rating::R
  end

  def rating_in_words
    { 1 => "G", 2 => "PG13", 3 => "R" }[self.rating]
  end

  # Constants
  # ========================================================
  class Rating
    G = 1
    PG13 = 2
    R = 3
  end

private
  # Two methods to keep the delayed_job job clean and without extra information
  def send_nudge_email
    Nudge.delay.send_nudge_email(self.id)
  end

  def self.send_nudge_email(nudge_id)
    nudge = Nudge.find(nudge_id)
    if nudge.sent_at.nil?
      UserMailer.nudge_notification(nudge.nudgee, nudge).deliver
      
      nudge.sent_at = Time.now
      nudge.save
    end
  end

end
