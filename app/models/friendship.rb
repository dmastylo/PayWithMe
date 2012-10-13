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