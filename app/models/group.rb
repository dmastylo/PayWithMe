# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Group < ActiveRecord::Base

  # Accesible attributes
  attr_accessible :description, :title

  # Validations
  validates :title, presence: true, length: { minimum: 2, maximum: 120 }

  # Relationships
  has_many :group_users
  has_many :members, class_name: "User", through: :group_users, source: :user, select: "users.*, group_users.admin"

  def self.search_by_title(query, user = nil)
    if user.nil?
      Group.search(title_cont: query).result
    else
      user.groups.search(title_cont: query).result
    end
  end

end