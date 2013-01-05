# == Schema Information
#
# Table name: news_items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  body       :string(255)
#  path       :string(255)
#  news_type  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  foreign_id :integer
#

require 'test_helper'

class NewsItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
