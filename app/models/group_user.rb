# == Schema Information
#
# Table name: group_users
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  group_id        :integer
#  admin           :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  invitation_sent :boolean          default(FALSE)
#

class GroupUser < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :group_id, :user_id

  # Relationships
  belongs_to :user
  belongs_to :group

end
