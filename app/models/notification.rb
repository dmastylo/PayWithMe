# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  notification_type :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  read              :boolean          default(FALSE)
#  foreign_id        :integer
#  foreign_type      :integer
#  subject_id        :integer
#

class Notification < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :notification_type, :foreign_id, :foreign_type, :subject_id

  # Validations
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
      foreign_id: event.id
      # body: "#{event.organizer.first_name} has invited you to #{event.title}.",
    )
  end

  def self.create_for_group(group, member)
    member.notifications.create(
      notification_type: NotificationType::INVITE,
      foreign_type: ForeignType::GROUP,
      foreign_id: group.id
      # body: "You have been added to #{group.title}.",
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

    # notification.body = "#{TextHelper.pluralize(message_count, 'new message has', 'new messages have')} been posted in #{event.title}."
    notification.subject_id = message_count
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

    # notification.body = "The details of #{event.title} have been updated."
    notification.read = false
    notification.save
  end

  def read!
    if !read?
      update_column(:read, true)
    end
  end

  def path
    if event?
      Rails.application.routes.url_helpers.event_path(event)
    elsif group?
      Rails.application.routes.url_helpers.group_path(group)
    end
  end

  def body
    if event?
      if invite?
        "#{event.organizer.first_name} has invited you to #{event.title}"
      elsif message?
        "#{TextHelper.pluralize(subject_id, 'new message has', 'new messages have')} been posted in #{event.title}."
      elsif update?
        "The details of #{event.title} have been updated."
      end
    elsif group?
      if invite?
        "You have been added to #{group.title}."
      end
    end
  end

  def event?
    foreign_type == ForeignType::EVENT
  end

  def group?
    foreign_type == ForeignType::GROUP
  end

  def message?
    notification_type == NotificationType::MESSAGE
  end

  def invite?
    notification_type == NotificationType::INVITE
  end

   def update?
    notification_type == NotificationType::UPDATE
  end

  def event
    if event?
      Event.find_by_id(foreign_id)
    end
  end

  def group
    if group?
      Group.find_by_id(foreign_id)
    end
  end

  def subject
    # For now, subject is always a user
    User.find_by_id(subject_id)
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
