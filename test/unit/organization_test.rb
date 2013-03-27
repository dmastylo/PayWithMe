# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  split             :boolean          default(TRUE)
#  deal              :boolean          default(TRUE)
#  comment           :string(255)
#  name              :string(255)
#  organization_name :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class RestrauntContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
