# == Schema Information
#
# Table name: group_users
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  group_id   :integer
#  admin      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GroupUser < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :admin, :group_id, :user_id

  # Relationships
  belongs_to :user
  belongs_to :group

end
