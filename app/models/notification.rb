class Notification < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :body, :category, :foreign_id

  # Validations
  validates :user_id, presence: true
  validates :body, presence: true
  validates :category, presence: true

  # Relationships
  belongs_to :user

  # Gets the url of a notification
  def url
    if self.category == "friend"
      Rails.application.routes.url_helpers.user_path(foreign_id)
    end
  end

end