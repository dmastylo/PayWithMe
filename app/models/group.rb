# == Schema Information
#
# Table name: groups
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  slug               :string(255)
#  organizer_id       :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_url          :string(255)
#

class Group < ActiveRecord::Base

  # Accesible attributes
  # ========================================================
  attr_accessible :description, :title, :image, :image_type, :image_url
  attr_accessor :image_type
  has_attached_file :image

  # Validations
  # ========================================================
  validates :organizer_id, presence: true
  validates :title, presence: true, length: { minimum: 2, maximum: 120, message: "has to be between 2 and 120 characters long"  }

  # Callbacks
  # ========================================================
  before_save :set_group_image
  before_destroy :clear_notifications_and_news_items
  before_destroy :transfer_member_list

  # Relationships
  # ========================================================
  belongs_to :organizer, class_name: "User"
  has_many :group_users, dependent: :destroy
  has_many :members, class_name: "User", through: :group_users, source: :user
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
    group_users = []
    event_users = []
    group_invite_notifications = []
    group_new_member_news = []

    members_to_add.each do |member|
      unless self.members.include?(member)
        group_users.push GroupUser.new(user_id: member.id, group_id: self.id)
        group_invite_notifications.push member.id unless member == exclude_from_notifications
        if editing_group
          group_new_member_news.push member.id
        end

        # Add the new member to the upcoming group events
        self.events.where('events.due_at > ?', Time.now).each do |event|
          event_users.push EventUser.new(user_id: member.id, event_id: event.id)
        end
      end
    end

    GroupUser.import group_users unless group_users.empty?
    EventUser.import event_users unless event_users.empty?
    Group.delay.send_invitation_emails(self.id) unless group_users.empty?
    Notification.delay.create_for_group(self.id, group_invite_notifications) unless group_invite_notifications.empty?
    NewsItem.delay.create_for_new_group_member(self.id, group_new_member_news) unless group_new_member_news.empty? || !editing_group
  end

  def add_member(member_to_add)
    self.add_members([member_to_add])
  end

  # Adds members and deletes any not in the set
  def set_members(members_to_set, exclude_from_notifications=nil)
    members_to_delete = []
    self.members.each do |member|
      if !members_to_set.include?(member)
        members_to_delete.push member
      end
    end
    self.members -= members_to_delete

    add_members(members_to_set, exclude_from_notifications)
  end

  def remove_members(members_to_remove)
    set_members(self.members - members_to_remove)
  end

  def remove_member(member_to_remove)
    remove_members([member_to_remove])
  end

  def is_admin?(user)
    user == organizer
  end

  def independent_members
    self.members - [organizer]
  end

  # def organizer
  #   group_user = self.group_users.where(admin: true).first
  #   if group_user.present?
  #     group_user.user
  #   else
  #     nil
  #   end
  # end

  def self.send_invitation_emails(group_id)
    group = Group.find_by_id(group_id, include: { group_users: :user })
    group.group_users.each do |group_user|
      if !group_user.invitation_sent? && group_user.user_id != self.organizer_id
        UserMailer.group_notification(group_user.user, self).deliver
        group_user.toggle(:invitation_sent).save
      end
    end
  end
  
  # Group Image functions
  # ========================================================
  def image_type
    if @image_type.present?
      @image_type
    elsif image.present?
      :upload
    elsif image_url.present?
      :url
    else
      :default_image
    end
  end

  # Static functions
  # ========================================================
  def self.search_by_title(query, user = nil)
    if user.nil?
      Group.search(title_cont: query).result
    else
      user.member_groups.search(title_cont: query).result
    end
  end

  # Returns a list of groups and their members from group ids
  def self.groups_and_members_from_params(params, user = nil)
    return [], [] if params.nil? || params.empty?
    params = ActiveSupport::JSON.decode(params)

    base = user.member_groups if user.present?
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

  def set_group_image
    return unless self.image_type.present?

    if self.image_type != "url"
      self.image_url = nil
    end

    if self.image_type != "upload"
      self.image = nil
    end

    image_type = nil
  end
end
