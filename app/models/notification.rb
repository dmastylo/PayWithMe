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
#  read              :boolean          default(FALSE)
#

class Notification < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :body, :path, :notification_type, :user_id

  # Validations
  validates :body, presence: true
  validates :notification_type, presence: true
  validates :user_id, presence: true

  # Relationships
  belongs_to :user

  # Creation methods
  def self.new_for_event(event, member)
    member.notifications.create(notification_type: NotificationType::Invite, body: "#{event.organizer.first_name} has invited you to #{event.title}.", path: Rails.application.routes.url_helpers.event_path(event))
  end

  def self.new_for_group(group, member)
    member.notifications.create(notification_type: NotificationType::Invite, body: "You have been added to #{group.title}.", path: Rails.application.routes.url_helpers.group_path(group))
  end

  def read!
    self.read = true
    self.save
  end

  # Constants
  class NotificationType
    Invite = 1
  end

end
