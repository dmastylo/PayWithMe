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
  attr_accessible :body, :path, :notification_type, :foreign_id, :foreign_type

  # Validations
  validates :body, presence: true
  validates :notification_type, presence: true
  validates :user_id, presence: true
  validates :foreign_id, presence: true

  # Relationships
  belongs_to :user

  # Creation methods
  def self.create_for_event(event, member)
    member.notifications.create(
      notification_type: NotificationType::INVITE,
      foreign_type: ForeignType::EVENT,
      body: "#{event.organizer.first_name} has invited you to #{event.title}.",
      foreign_id: event.id
    )
  end

  def self.create_for_group(group, member)
    member.notifications.create(
      notification_type: NotificationType::INVITE,
      foreign_type: NotificationType::GROUP,
      body: "You have been added to #{group.title}.",
      foreign_id: group.id
    )
  end

  def self.create_or_update_for_event_message(event, member)
    last_message = member.messages.where(event_id: event.id).first
    message_after = (last_message.present?)? last_message.created_at : Time.now.midnight
    message_count = event.messages.where("created_at > ?", message_after).count
    return unless message_count > 0

    notification = member.notifications.where(
      foreign_id: event.id,
      notification_type: NotificationType::MESSAGE,
      foreign_type: ForeignType::EVENT,
      created_at: (Time.now.midnight)..Time.now.midnight + 1.day
    ).first
    if notification.nil?
      notification = member.notifications.new(
        notification_type: NotificationType::MESSAGE,
        foreign_type: ForeignType::EVENT,
        foreign_id: event.id
      )
    end

    notification.body = "#{TextHelper.pluralize(message_count, 'new message has', 'new messages have')} been posted in #{event.title}."
    notification.read = false
    notification.save
  end

  def self.create_or_update_for_event_update(event, member)
    notification = member.notifications.where(
      foreign_id: event.id,
      notification_type: NotificationType::UPDATE,
      foreign_type: ForeignType::EVENT,
      created_at: (Time.now.midnight)..Time.now.midnight + 1.day
    ).first
    if notification.nil?
      notification = member.notifications.new(
        notification_type: NotificationType::UPDATE,
        foreign_type: ForeignType::EVENT,
        foreign_id: event.id
      )
    end

    notification.body = "The details of #{event.title} have been updated."
    notification.read = false
    notification.save
  end

  def read!
    if !read?
      update_column(:read, true)
    end
  end

  def path
    if foreign_type == ForeignType::EVENT
      Rails.application.routes.url_helpers.event_path(foreign_id)
    elsif foreign_type == ForeignType::GROUP
      Rails.application.routes.url_helpers.group_path(foreign_id)
    end
  end

  # Constants
  class NotificationType
    INVITE = 1
    MESSAGE = 2
    UPDATE = 3
  end
  class ForeignType
    EVENT = 1
    GROUP = 2
  end

end
