class Notification < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :body, :path, :type, :user_id

  # Validations
  validates :body, presence: true
  validates :type, presence: true
  validates :user_id, presence: true

  # Relationships
  belongs_to :user

end