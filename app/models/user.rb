# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0)
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :string(255)
#  last_sign_in_ip            :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  name                       :string(255)
#  profile_image_file_name    :string(255)
#  profile_image_content_type :string(255)
#  profile_image_file_size    :integer
#  profile_image_updated_at   :datetime
#  profile_image_url          :string(255)
#  stub                       :boolean          default(FALSE)
#  guest_token                :string(255)
#  using_oauth                :boolean
#  last_seen                  :datetime
#

class User < ActiveRecord::Base

  # Devise modules
  # ========================================================
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Accessible attributes
  # ========================================================
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :profile_image, :profile_image_option, :profile_image_url
  attr_accessor :profile_image_option
  has_attached_file :profile_image, styles: { thumb: "#{Figaro.env.thumb_size}x#{Figaro.env.thumb_size}>", small: "#{Figaro.env.small_size}x#{Figaro.env.small_size}>", medium: "#{Figaro.env.medium_size}x#{Figaro.env.medium_size}>" }

  # Validations
  # ========================================================
  validates :name, presence: true, length: { maximum: 50 }, unless: :stub?
  validates :password, length: { minimum: 8 }, if: :password_required?, unless: :stub?
  
  # Callbacks
  # ========================================================
  before_save :set_profile_image
  before_save :set_stub
  after_create :set_last_seen

  # Relationships
  # ========================================================
  has_many :organized_events, class_name: "Event", foreign_key: "organizer_id"
  has_many :event_users, dependent: :destroy
  has_many :member_events, class_name: "Event", through: :event_users, source: :event, select: "events.*, event_users.amount_cents, event_users.due_date, event_users.paid_date"
  has_many :group_users, dependent: :destroy
  has_many :groups, through: :group_users, source: :group, select: "groups.*, group_users.admin"
  has_many :messages, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :linked_accounts, dependent: :destroy
  has_many :news_items, dependent: :destroy

  # Scopes
  # ========================================================
  scope :online, lambda{ where("last_seen > ?", 3.minutes.ago) }

  # Profile Image
  # ========================================================
  def profile_image_type
    if profile_image.present?
      :upload
    elsif profile_image_url.present?
      :url
    else
      :gravatar
    end
  end

  # Static functions
  # ========================================================
  # Returns a list of users from email addresses, creating stub units as necessary
  def self.from_params(params)
    return [] if params.nil? || params.empty?
    params = ActiveSupport::JSON.decode(params)
    users = []

    params.each do |email|
      user = User.find_by_email(email)
      if user.nil?
        user = User.create_stub(email)
      end

      users.push user
    end

    users.uniq
  end

  def self.create_stub(email)
    user = User.new(email: email)
    user.stub = true
    user.save
    user.guest_token = ::BCrypt::Password.create("#{email}#{user.created_at.to_s}#{pepper}")
    user.save
    user
  end

  def self.from_omniauth(auth)
    linked_account = LinkedAccount.where(auth.slice(:provider, :uid)).first

    if linked_account.present?
      linked_account.user
    else
      User.new do |user|
        user.name = auth.info.name if auth.info.name
        user.email = auth.info.email if auth.info.email
        user.using_oauth = true
      end
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.search_by_name_and_email(query)
    User.search(name_or_email_cont: query).result
  end

  def profile_image_type
    if profile_image.present?
      :upload
    elsif profile_image_url.present?
      :url
    else
      :gravatar
    end
  end

  # Instance methods
  # ========================================================
  def password_required?
    super && !using_oauth? && !stub?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def can_post_message?
    self.messages.all.empty? || Time.now.to_i - self.messages.all.first.created_at.to_i > Figaro.env.chat_limit.to_i
  end

  def online?
    self.last_seen > 3.minutes.ago
  end

  def first_name
    if name.present?
      name.split(" ").first
    else
      ""
    end
  end

  def has_notifications?
    self.notifications.count > 0
  end

  def current_notifications
    self.notifications.order('created_at DESC').paginate(per_page: 5, page: 1)
  end

  def has_unread_notifications?
    self.unread_notifications.count > 0
  end

  def unread_notifications
    self.notifications.where(read: false)
  end

  # Event Definitions
  # ========================================================
  def upcoming_organized_events
    self.organized_events.where('start_at > ?', Time.now).order("start_at ASC")
  end

  def past_organized_events
    self.organized_events.where('start_at < ?', Time.now).order("start_at DESC")
  end

  def upcoming_events
    self.member_events.where('start_at > ?', Time.now).order("start_at ASC")
  end

  def limited_upcoming_events
    self.member_events.where('start_at > ?', Time.now).order("start_at ASC").limit(5)
  end

  def past_events
    self.member_events.where('start_at < ?', Time.now).order("start_at DESC")
  end
  
  def invited_events
    self.member_events.delete_if { |event| event.organizer == self }
  end

  def facebook_account
    self.linked_accounts.where(provider: :facebook).first
  end

  def twitter_account
    self.linked_accounts.where(provider: :twitter).first
  end

  def paypal_account
    self.linked_accounts.where(provider: :paypal).first
  end

  def upcoming_invited_events
    self.member_events.where('start_at > ?', Time.now).order("start_at ASC").delete_if { |event| event.organizer == self }
  end

  def past_invited_events
    self.member_events.where('start_at < ?', Time.now).order("start_at DESC").delete_if { |event| event.organizer == self }
  end

private
  def set_profile_image
    return unless self.profile_image_option.present?
    
    if self.profile_image_option != "url"
      self.profile_image_url = nil
    end
    if self.profile_image_option != "upload"
      self.profile_image = nil
    end

    profile_image_option = nil
  end

  def set_stub
    if encrypted_password.present? || using_oauth?
      stub = false
      guest_token = nil
    end
  end

  def set_last_seen
    self.last_seen = Time.now
  end
  
end
