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
#  subject_id   :integer
#  read         :boolean          default(FALSE)
#

class NewsItem < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :news_type, :foreign_id, :foreign_type, :subject_id, :read

  # Validations
  validates_presence_of :title, :news_type, :foreign_type, :user_id, :foreign_id

  # Relationships
  belongs_to :user

  # Creation Methods
  def self.create_for_new_event_member(event, new_member)
    values = {
      news_type: NewsType::INVITE,
      foreign_type: ForeignType::EVENT,
      foreign_id: event.id,
      subject_id: new_member.id
    }
    event.members.each do |member|
      unless member == new_member || member == event.organizer
        member.news_items.create!(values)
      end
    end
  end

  def self.create_for_new_messages(event, message_creator)
    values = {
      news_type: NewsType::MESSAGE,
      foreign_type: ForeignType::EVENT,
      foreign_id: event.id
    }
    event.members.each do |member|
      unless member == message_creator
        member_news_items = member.news_items # Prevent multiple database queries below
        if (!member_news_items.empty? && member_news_items.first.message? && member_news_items.first.foreign_id == event.id)
          member.news_items.first.update_attributes(read: false)
        else
          member.news_items.create!(values)
         end
      end
    end
  end

  def self.create_for_new_group_member(group, new_member)
    values = {
      news_type: NewsType::INVITE,
      foreign_type: ForeignType::GROUP,
      foreign_id: group.id,
      subject_id: new_member.id
    }
    group.members.each do |member|
      unless member == new_member || group.is_admin?(member)
        member.news_items.create!(values)
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
        name = subject.first_name.present?? subject.first_name : subject.email
        "#{name} is now attending #{event.title}."
      elsif message?
        "Check out #{event.title} to see the ongoing discussion."
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
        "#{event.title} has a new attendee!"
      elsif message?
        "#{event.title} has new messages!"
      end
    elsif group?
      if invite?
        "#{group.title} has a new member!"
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

  def subject
    # For now, subject is always a user
    User.find_by_id(subject_id)
  end

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
