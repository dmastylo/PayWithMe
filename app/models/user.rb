class User < ActiveRecord::Base
  
  # Devise
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Accessible Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :uid, :username, :image

  # Callbacks
  before_validation :set_password

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  # Relationships
  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :notifications

  # Finds a user based on their oAuth provider and identification
  def self.find_for_oauth(auth, signed_in_resource=nil)
    User.where(:provider => auth.provider, :uid => auth.uid).first
  end

  # Returns all of the users friendships
  def friends
    self.friendships + self.inverse_friendships
  end

  # Searches the users friends for *name*
  def find_friends_by_name(name)
    results = []
    friends.each { |friendship|
      if friendship.friend == self
        friend = friendship.user
      else
        friend = friendship.friend
      end

      results.push(friend) if /#{name}/i.match(friend.name)
    }
    results
  end

  # Sends a friend request to a user
  def send_friend_request!(user)
    Friendship.create(user_id: self.id, friend_id: user.id, accepted: 0)
    user.notifications.create(category: "friend", body: "#{self.name} has sent you a friend request.", foreign_id: self.id)
  end

  # Determines if a user is a friend
  def friends_with?(user)
    current_id = self.id
    friendship = Friendship.where{((user_id == current_id) & (friend_id == user.id)) | ((friend_id == current_id) & (user_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 1
  end

  # Determines if a friend request has been sent to a user
  def friends_sent?(user)
    current_id = self.id
    friendship = Friendship.where{((user_id == current_id) & (friend_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 0
  end

  # Determines if a friend request has been received from a user
  def friends_received?(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 0
  end

  # Accepts a friend request that was received from a user
  def accept_friend!(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    friendship.accepted = 1
    friendship.save

    notifications = Notification.where{((category == "friend") && (user_id == current_id) && (foreign_id == user.id))}.first
    notifications.each { |notification| notification.destroy }
  end

  # Denies a friend request that was received from a user
  def deny_friend!(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    friendship.destroy

    notifications = Notification.where{((category == "friend") && (user_id == current_id) && (foreign_id == user.id))}.first
    notifications.each { |notification| notification.destroy }
  end

  # Gets the five most recent notifications
  def current_notifications
    self.notifications.slice(0, 5)
  end

  # Determines if a user has any read or unread notifications
  def has_notifications?
    !self.notifications.empty?
  end

  # Determines if a user has any unread notifications
  def has_unread_notifications?
    !unread_notifications.empty?
  end

  # Gets all of a users unread notifications
  def unread_notifications
    self.notifications.where({read: 0})
  end

private

  # Sets a password if a provider is used since a normal login won't
  def set_password
    if self.provider
      self.password = Devise.friendly_token[0,20]
      self.password_confirmation = self.password
    end
  end
end
