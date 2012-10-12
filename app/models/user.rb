class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :uid, :username, :image
  # attr_accessible :title, :body

  before_validation :set_password

  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :notifications

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    User.where(:provider => auth.provider, :uid => auth.uid).first
  end

  def friends
    self.friendships + self.inverse_friendships
  end

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

  def send_friend_request!(user)
    Friendship.create(user_id: self.id, friend_id: user.id, accepted: 0)
    user.notifications.create(category: "friend", body: "#{self.name} has sent you a friend request.", foreign_id: self.id)
  end

  def friends_with?(user)
    current_id = self.id
    friendship = Friendship.where{((user_id == current_id) & (friend_id == user.id)) | ((friend_id == current_id) & (user_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 1
  end

  def friends_sent?(user)
    current_id = self.id
    friendship = Friendship.where{((user_id == current_id) & (friend_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 0
  end

  def friends_received?(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    !friendship.nil? && friendship.accepted == 0
  end

  def accept_friend!(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    friendship.accepted = 1
    friendship.save

    notifications = Notification.where{((category == "friend") && (user_id == current_id) && (foreign_id == user.id))}.first
    notifications.each { |notification| notification.destroy }
  end

  def deny_friend!(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    friendship.destroy

    notifications = Notification.where{((category == "friend") && (user_id == current_id) && (foreign_id == user.id))}.first
    notifications.each { |notification| notification.destroy }
  end

  def current_notifications
    self.notifications.slice(0, 5)
  end

  def has_notifications?
    !self.notifications.empty?
  end

  def has_unread_notifications?
    !unread_notifications.empty?
  end

  def unread_notifications
    self.notifications.where({read: 0})
  end

  private
    def set_password
      # Sets a password if a provider is used since a normal login won't
      if self.provider
        self.password = Devise.friendly_token[0,20]
        self.password_confirmation = self.password
      end
    end
end
