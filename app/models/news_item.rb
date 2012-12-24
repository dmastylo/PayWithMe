# == Schema Information
#
# Table name: news_items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :string(255)
#  path       :string(255)
#  read       :boolean          default(FALSE)
#  type       :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  foreign_id :integer
#

class NewsItem < ActiveRecord::Base
    # Accessible Attributes
    attr_accessible :body, :path, :read, :title, :type, :foreign_id

    # Validations
    validates_presence_of :title, :body, :path, :read, :type, :user, :foreign_id

    # Relationships
    belongs_to :user

    # Creation Methods
    def self.create_for_new_event_user(event, event_user)
        values = {
            type: Type::NEW_EVENT_USER,
            foreign_id: event.id,
            title: event.title + " has a new attendee!",
            body: event_user.member.name + " is now attending " + event.title + "!",
            path: Rails.application.routes.url_helpers.event_path(event)
        }
        event.members.each do |member|
            member.news_items.create(values)
        end
    end

    # TODO
    # def self.create_for_new_messages(event)
    #     values = {
    #         type: Type::NEW_MESSAGES,
    #         foreign_id: event.id,
    #         title: "", # TODO
    #         body: "", # TODO
    #         path: Rails.application.routes.url_helpers.event_path(event)
    #     }
    #     event.members.each do |member|
    #         member.news_items.create(values)
    #     end
    # end

    # TODO
    # def self.create_for_new_group_user(group)
    #     values = {
    #         type: Type::NEW_GROUP_USER,
    #         foreign_id: group.id,
    #         title: "", # TODO
    #         body: "", # TODO
    #         path: Rails.application.routes.url_helpers.group_path(group)
    #     }
    #     group.members.each do |member|
    #         member.news_items.create(values)
    #     end
    # end

    # Constants
    class Type
        NEW_EVENT_USER = 1
        NEW_GROUP_USER = 2
        NEW_MESSAGES = 3
    end
end
