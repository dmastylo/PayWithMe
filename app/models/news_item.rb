# == Schema Information
#
# Table name: news_items
#
#  id           :integer          not null, primary key
#  news_type    :integer
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  foreign_id   :integer
#  foreign_type :integer
#  read         :boolean          default(FALSE)
#

class NewsItem < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :news_type, :foreign_id, :foreign_type, :subjects, :read

  # Validations
  validates_presence_of :news_type, :foreign_type, :user_id, :foreign_id

  # Relationships
  belongs_to :user
  has_and_belongs_to_many :subjects, class_name: "User"

  # Creation Methods
  def self.create_for_new_event_member(event, new_member)
    values = {
      news_type: NewsType::INVITE,
      foreign_type: ForeignType::EVENT,
      foreign_id: event.id
    }

    event = Event.find_by_id(event.id, include: {event_users: :user})
    event.event_users.each do |event_user|
      user = event_user.user
      unless user == new_member || user == event.organizer
        news_item = user.news_items.where(values).first

        if news_item.nil? || news_item.created_at < 2.hours.ago
          news_item = user.news_items.create(values)
        end

        if !news_item.subjects.include?(new_member)
          news_item.subjects << new_member
        end
        news_item.unread!
      end
    end
  end

  def self.create_for_new_messages(event, message_creator)
    values = {
      news_type: NewsType::MESSAGE,
      foreign_type: ForeignType::EVENT,
      foreign_id: event.id
    }
    
    event = Event.find_by_id(event.id, include: {event_users: :user})
    event.event_users.each do |event_user|
      user = event_user.user
      unless user == message_creator
        news_item = user.news_items.where(values).first

        if news_item.nil? || news_item.created_at < 2.hours.ago
          news_item = user.news_items.create(values)
        end

        if !news_item.subjects.include?(message_creator)
          news_item.subjects << message_creator
        end
        
        if event_user.on_page?
          news_item.read!
        else
          news_item.unread!
        end
      end
    end
  end

  def self.create_for_new_group_member(group, new_member)
    values = {
      news_type: NewsType::INVITE,
      foreign_type: ForeignType::GROUP,
      foreign_id: group.id
    }

    group = Group.find_by_id(group.id, include: {event_users: :user})
    group.group_users.each do |group_user|
      user = group_user.user
      unless user == new_member || user == group.organizer
        news_item = user.news_items.where(values).first

        if news_item.nil? || news_item.created_at < 2.hours.ago
          news_item = user.news_items.create(values)
        end

        if !news_item.subjects.include?(new_member)
          news_item.subjects << new_member
        end
        news_item.unread!
      end
    end
  end

  # Scope
  default_scope order('updated_at DESC')

  def read!
    if !read?
      update_column(:read, true)
    end
  end

  def body
    if event?
      if invite?
        name = "name"
        "#{name} is now attending #{event.title}."
      elsif message?
        "Check out #{event.title} to see the ongoing discussion. New messages from:"
      end
    elsif group?
      if invite?
        "#{subject.first_name} is now a member of #{group.title}."
      end
    end
  end

  def path
    if event?
      Rails.application.routes.url_helpers.event_path(event)
    elsif group?
      Rails.application.routes.url_helpers.group_path(group)
    end
  end

  def title
    if event?
      if invite?
        "#{event.title} has #{subjects.count == 1 ? "a new attendee" : "new attendees"}!"
      elsif message?
        "#{event.title} has new messages!"
      end
    elsif group?
      if invite?
        "#{group.title} has  #{subjects.count == 1 ? "a new member" : "new members"}!"
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
    news_type == NewsType::MESSAGE
  end

  def invite?
    news_type == NewsType::INVITE
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

  def unread!
    self.read = false
    save
  end

  # def subject
  #   # For now, subject is always a user
  #   User.find_by_id(subject_id)
  # end

  # def subjects
  #   [subject]
  # end

  # Constants
  class NewsType
    INVITE = 1
    MESSAGE = 2
  end
  class ForeignType
    EVENT = 1
    GROUP = 2
  end

end
