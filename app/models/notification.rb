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
  attr_accessible :body, :path, :notification_type, :foreign_id

  # Validations
  validates :body, presence: true
  validates :notification_type, presence: true
  validates :user_id, presence: true
  validates :foreign_id, presence: true
  validates :path, presence: true

  # Relationships
  belongs_to :user

  # Creation methods
  def self.create_for_event(event, member)
    member.notifications.create(notification_type: NotificationType::Invite, body: "#{event.organizer.first_name} has invited you to #{event.title}.", path: Rails.application.routes.url_helpers.event_path(event), foreign_id: event.id)
  end

  def self.create_for_group(group, member)
    member.notifications.create(notification_type: NotificationType::Invite, body: "You have been added to #{group.title}.", path: Rails.application.routes.url_helpers.group_path(group), foreign_id: group.id)
  end

  def self.create_or_update_for_event_message(event, member)
    last_message = member.messages.where(event_id: event.id).first
    message_after = (last_message.present?)? last_message.created_at : Time.now.midnight
    message_count = event.messages.where("created_at > ?", message_after).count
    return unless message_count > 0

    notification = member.notifications.where(foreign_id: event.id, notification_type: NotificationType::Message, created_at: (Time.now.midnight)..Time.now.midnight + 1.day).first
    if notification.nil?
      notification = member.notifications.new(notification_type: NotificationType::Message, path: Rails.application.routes.url_helpers.event_path(event), foreign_id: event.id)
    end

    notification.body = "#{TextHelper.pluralize(message_count, 'new message has', 'new messages have')} been posted in #{event.title}."
    notification.read = false
    notification.save
  end

  def read!
    update_column(:read, true)
  end

  # Constants
  class NotificationType
    Invite = 1
    Message = 2
  end

end
