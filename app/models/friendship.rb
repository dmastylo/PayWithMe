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

# Friendship is the junction for User to User relationships

class Friendship < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :friend_id, :user_id, :accepted

  # Validations
  validates :friend_id, presence: true
  validates :user_id, presence: true

  # Relationships
  belongs_to :user
  belongs_to :friend, class_name: "User"

end
