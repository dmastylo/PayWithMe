# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  notification_type :integer
#  body              :string(255)
#  path              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Notification < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :body, :path, :type, :user_id

  # Validations
  validates :body, presence: true
  validates :type, presence: true
  validates :user_id, presence: true

  # Relationships
  belongs_to :user

  # Creation methods
  def self.new_for_event(event, member)
    member.notifications.create(notification_type: NotificationType::Invite, body: "#{event.organizer.first_name} has invited you to #{event.title}.", path: Rails.application.routes.url_helpers.event_path(event))
  end

  # Constants
  class NotificationType
    Invite = 1
  end

end
