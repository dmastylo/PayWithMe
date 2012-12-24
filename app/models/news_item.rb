# == Schema Information
#
# Table name: news_items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :string(255)
#  path       :string(255)
#  read       :boolean
#  type       :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class NewsItem < ActiveRecord::Base
  belongs_to :user
  attr_accessible :body, :path, :read, :title, :type
end
