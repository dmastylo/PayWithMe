# == Schema Information
#
# Table name: groups
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  slug        :string(255)
#

class Group < ActiveRecord::Base

  # Accesible attributes
  # ========================================================
  attr_accessible :description, :title

  # Validations
  # ========================================================
  validates :title, presence: true, length: { minimum: 2, maximum: 120, message: "has to be between 2 and 120 characters long"  }

  # Callbacks
  # ========================================================
  before_destroy :clear_notifications_and_news_items
  before_destroy :transfer_member_list

  # Relationships
  # ========================================================
  has_many :group_users, dependent: :destroy
  has_many :members, class_name: "User", through: :group_users, source: :user, select: "users.*, group_users.admin"
  has_many :event_groups, dependent: :destroy
  has_many :events, through: :event_groups, source: :event

  # Pretty URLs
  # ========================================================
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # Member definitions
  # ========================================================
  def add_members(members_to_add, exclude_from_notifications=nil)
    editing_group = true if self.members.length != 0
    members_to_add.each do |member|
      unless self.members.include?(member)
        self.members << member
        Notification.create_for_group(self, member) if member != exclude_from_notifications
        if editing_group
            NewsItem.delay.create_for_new_group_member(self, member)
        end
      end
    end

    delay.send_invitation_emails
    # Later, add them to open events as of
    # right now if they are added to the group
  end

  # Adds members and deletes any not in the set
  def set_members(members_to_set, exclude_from_notifications=nil)
    self.members.each do |member|
      if !members_to_set.include?(member)
        self.members.delete(member)
      end
    end

    add_members(members_to_set, exclude_from_notifications)
  end

  def is_admin?(user)
    self.group_users.find_by_user_id(user.id).admin?
  end

  def organizer
    group_user = self.group_users.where(admin: true).first
    if group_user.present?
      group_user.user
    else
      nil
    end
  end

  def send_invitation_emails
    self.group_users.each do |group_user|
      if !group_user.invitation_sent? && !group_user.admin?
        UserMailer.group_notification(group_user.user, self).deliver
        group_user.toggle(:invitation_sent).save
      end
    end
  end

  # Static functions
  # ========================================================
  def self.search_by_title(query, user = nil)
    if user.nil?
      Group.search(title_cont: query).result
    else
      user.groups.search(title_cont: query).result
    end
  end

  # Returns a list of groups and their members from group ids
  def self.groups_and_members_from_params(params, user = nil)
    return [], [] if params.nil? || params.empty?
    params = ActiveSupport::JSON.decode(params)

    base = user.groups if user.present?
    base ||= Group

    users = []
    groups = []
    params.each do |group|
      group = base.find_by_id(group)
      if group.present?
        groups.push group
        users += group.members
      end
    end

    return groups.uniq, users.uniq
  end

private
  def clear_notifications_and_news_items
    Notification.where(foreign_id: self.id, foreign_type: Notification::ForeignType::GROUP).destroy_all
    NewsItem.where(foreign_id: self.id, foreign_type: NewsItem::ForeignType::GROUP).destroy_all
  end

  def transfer_member_list
    # TODO
    # transfer the group users into the members
    self.events.each do |event|
      event.remove_group(self)
    end
  end

end
