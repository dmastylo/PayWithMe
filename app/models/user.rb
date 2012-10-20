# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  provider               :string(255)
#  uid                    :string(255)
#  username               :string(255)
#  image                  :string(255)
#

class User < ActiveRecord::Base

  # Devise
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Accessible Attributes
  attr_accessor :provider, :uid, :token, :using_oauth
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :uid, :token, :username, :image, :using_oauth

  # Callbacks
  before_validation :set_password

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true

  # Relationships
  has_many :friendships
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :notifications
  has_many :owed_payments, class_name: "Payment", foreign_key: "payer_id"
  has_many :expected_payments, class_name: "Payment", foreign_key: "payee_id"
  has_many :linked_accounts

  # Finds a user based on their oAuth provider and identification
  def self.find_for_oauth(auth, signed_in_resource=nil)
    @account = LinkedAccount.where(:provider => auth.provider, :uid => auth.uid).first
    if @account
      @account.user
    else
      nil
    end
  end

  # Returns all of the users friendships
  # TODO: Optimize this
  def friends
    friends = []
    (self.friendships + self.inverse_friendships).each do |friendship|
      if friendship.friend == self
        friends.push(friendship.user)
      else
        friends.push(friendship.friend)
      end
    end

    friends
  end

  # Searches the users friends for *name*
  def find_friends_by_name(name)
    found_friends = friends
    found_friends.delete_if { |friend| } #{name}/i.match(friend.name) }
    found_friends
  end

  # Sends a friend request to a user
  def send_friend_request!(user)
    Friendship.create(user_id: self.id, friend_id: user.id, accepted: 0)
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
  end

  # Denies a friend request that was received from a user
  def deny_friend!(user)
    current_id = self.id
    friendship = Friendship.where{((friend_id == current_id) & (user_id == user.id))}.first
    friendship.destroy
  end

  # Gets the five most recent notifications
  def current_notifications
    self.notifications.find(:all, order: 'created_at DESC').slice(0, 5)
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
    self.notifications.where(read: 0).order('created_at DESC')
  end

private

  # Sets a password if a provider is used since a normal login won't
  def set_password
    if self.using_oauth
      self.password = Devise.friendly_token[0,20]
      self.password_confirmation = self.password
      self.using_oauth = nil
    end
  end
end