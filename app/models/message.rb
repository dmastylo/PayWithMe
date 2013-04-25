# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  message    :string(255)
#  event_id   :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Message < ActiveRecord::Base
  
  # Callbacks
  after_create :notify_news_feed

  # Accessible attributes
  attr_accessible :message

  # Validations
  validates_presence_of :message, :event, :user

  # Relationships
  belongs_to :event
  belongs_to :user

  # Scope
  default_scope order('created_at DESC')

private
  def notify_news_feed
    NewsItem.delay.create_for_new_messages(self.event_id, self.user_id)
  end
end
