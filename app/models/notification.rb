# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  category   :string(255)
#  body       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  foreign_id :integer
#  read       :integer
#

class Notification < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :body, :category, :foreign_id, :read

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
    elsif self.category == "payment"
      Rails.application.routes.url_helpers.payments_path
    end
  end

end
