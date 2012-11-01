# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  friend_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  accepted   :integer
#

require 'spec_helper'

describe Friendship do

  describe "accessible attributes" do
    it "should not allow access to accepted" do
      expect do
        Friendship.new(accepted: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

end
