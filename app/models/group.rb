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
  has_many :group_users, dependent: :destroy
  has_many :members, class_name: "User", through: :group_users, source: :user, select: "users.*, group_users.admin"
  has_many :event_groups, dependent: :destroy
  has_many :events, through: :event_groups, source: :event

  def add_members(members)
  end

  def self.search_by_title(query, user = nil)
    if user.nil?
      Group.search(title_cont: query).result
    else
      user.groups.search(title_cont: query).result
    end
  end

  def self.groups_and_members_from_params(params, user = nil)
    return if params.empty?
    params = ActiveSupport::JSON.decode(params)

    base = user.groups if user.present?
    base ||= Group

    users = groups = []
    params.each do |group|
      group = base.find_by_id(group)
      if group.present?
        groups += group
        users += group.members
      end
    end

    return groups.uniq, users.uniq
  end

end