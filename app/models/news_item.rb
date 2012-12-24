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
#

class NewsItem < ActiveRecord::Base
  attr_accessible :body, :path, :read, :title, :type

  validates_presence_of :title, :body, :path, :read, :type, :user

  belongs_to :user
end
