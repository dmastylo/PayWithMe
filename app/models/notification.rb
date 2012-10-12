class Notification < ActiveRecord::Base
  attr_accessible :body, :category, :foreign_id

  belongs_to :user

  validates :user_id, presence: true
  validates :body, presence: true
  validates :category, presence: true

  def url
    if self.category == "friend"
      user_path(user_id)
    end
  end
end
