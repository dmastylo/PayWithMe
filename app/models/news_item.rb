# == Schema Information
#
# Table name: news_items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :string(255)
#  path       :string(255)
#  read       :boolean          default(FALSE)
#  news_type  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  foreign_id :integer
#

class NewsItem < ActiveRecord::Base
    # Accessible Attributes
    attr_accessible :body, :path, :read, :title, :news_type, :foreign_id

    # Validations
    validates_presence_of :title, :body, :path, :news_type, :user_id, :foreign_id

    # Relationships
    belongs_to :user

    # Creation Methods
    def self.create_for_new_event_member(event, new_member)
        values = {
            news_type: Type::NEW_EVENT_USER,
            foreign_id: event.id,
            title: '"' + event.title + '" has a new attendee!',
            body: new_member.name + ' is now attending "' + event.title + '"!',
            path: Rails.application.routes.url_helpers.event_path(event),
        }
        event.members.each do |member|
            unless member == new_member || member == event.organizer
                member.news_items.create!(values)
            end
        end
    end

    def self.create_for_new_messages(event, message_creator)
        values = {
            news_type: Type::NEW_MESSAGES,
            foreign_id: event.id,
            title: '"' + event.title + '" has new messages!',
            body: 'Check out "' + event.title + '" to see the ongoing discussion!',
            path: Rails.application.routes.url_helpers.event_path(event)
        }
        event.members.each do |member|
            unless member == message_creator
                member_news_items = member.news_items # Prevent multiple database queries in conditional checking
                if (!member_news_items.empty? && member_news_items.first.news_type == Type::NEW_MESSAGES && member_news_items.first.foreign_id = event.id)
                    member.news_items.first.touch
                else
                    member.news_items.create!(values)
                end
            end
        end
    end

    def self.create_for_new_group_member(group, new_member)
        values = {
            news_type: Type::NEW_GROUP_USER,
            foreign_id: group.id,
            title: '"' + group.title + '" has a new member!',
            body: new_member.name + ' is now a member of "' + group.title + '"!',
            path: Rails.application.routes.url_helpers.group_path(group)
        }
        group.members.each do |member|
            unless member == new_member || group.is_admin?(member)
                member.news_items.create!(values)
            end
        end
    end

    # Scope
    default_scope order('updated_at DESC')

    # Constants
    class Type
        NEW_EVENT_USER = 1
        NEW_GROUP_USER = 2
        NEW_MESSAGES = 3
    end
end