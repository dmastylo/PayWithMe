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
  attr_accessible :notification_type, :foreign_id, :foreign_type, :subject_id, :user_id

  # Validations
  validates :notification_type, presence: true
  validates :user_id, presence: true
  validates :foreign_id, presence: true

  # Relationships
  belongs_to :user

  # Creation methods
  def self.create_for_event(event_id, user_ids)
    notifications = []
    user_ids.each do |user_id|
      notifications.push Notification.new(
        notification_type: NotificationType::INVITE,
        foreign_type: ForeignType::EVENT,
        foreign_id: event_id,
        user_id: user_id
      )
    end
    Notification.import notifications
  end

  def self.create_for_group(group_id, user_ids)
    notifications = []
    user_ids.each do |user_id|
      notifications.push Notification.new(
        notification_type: NotificationType::INVITE,
        foreign_type: ForeignType::GROUP,
        foreign_id: group_id,
        user_id: user_id
      )
    end
    Notification.import notifications
  end

  def self.create_or_update_for_event_message(event, user_ids)
    event_id = event.id
    
    user_ids.each do |user_id|
      user = User.find_by_id(user_id)

      last_message = user.messages.where(event_id: event_id).first
      message_after = (last_message.present?) ? last_message.created_at : Time.now.midnight
      message_count = event.messages.where("created_at > ?", message_after).count
      next unless message_count > 0

      notification = user.notifications.where(
        foreign_id: event_id,
        notification_type: NotificationType::MESSAGE,
        foreign_type: ForeignType::EVENT,
        created_at: (Time.now.midnight)..Time.now.midnight + 1.day
      ).first
      if notification.nil?
        notification = user.notifications.new(
          notification_type: NotificationType::MESSAGE,
          foreign_type: ForeignType::EVENT,
          foreign_id: event_id
        )
      end

      notification.subject_id = message_count
      notification.read = false
      notification.save
    end
  end

  def self.create_or_update_for_event_update(event_id, user_ids)
    user_ids.each do |user_id|
      user = User.find_by_id(user_id)
      
      notification = user.notifications.where(
        foreign_id: event_id,
        notification_type: NotificationType::UPDATE,
        foreign_type: ForeignType::EVENT,
        created_at: (Time.now.midnight)..Time.now.midnight + 1.day
      ).first
      if notification.nil?
        notification = user.notifications.new(
          notification_type: NotificationType::UPDATE,
          foreign_type: ForeignType::EVENT,
          foreign_id: event_id
        )
      end

      # notification.body = "The details of #{event.title} have been updated."
      notification.read = false
      notification.save
    end
  end

  def self.create_for_not_participating(event, user)
    notification = event.organizer.notifications.new(
      notification_type: NotificationType::NOT_PARTICIPATING,
      foreign_type: ForeignType::EVENT,
      foreign_id: event.id,
      subject_id: user.id
    )

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
        "#{event.organizer.first_name} has invited you to #{event.title}."
      elsif message?
        "#{TextHelper.pluralize(subject_id, 'new message has', 'new messages have')} been posted in #{event.title}."
      elsif update?
        "The details of #{event.title} have been updated."
      elsif not_participating?
        "#{(subject.first_name.empty?)? subject.email : subject.first_name} has decided to not participate in #{event.title}"
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

  def not_participating?
    notification_type == NotificationType::NOT_PARTICIPATING
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
    NOT_PARTICIPATING = 4
  end
  class ForeignType
    EVENT = 1
    GROUP = 2
  end

end
