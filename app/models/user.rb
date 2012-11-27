class User < ActiveRecord::Base
  # Devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Accessible attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :profile_image_option, :profile_image, :profile_image_option, :profile_image_url
  attr_accessor :profile_image_option
  has_attached_file :profile_image, styles: { thumb: "#{Figaro.env.thumb_size}x#{Figaro.env.thumb_size}>", small: "#{Figaro.env.small_size}x#{Figaro.env.small_size}>", medium: "#{Figaro.env.medium_size}x#{Figaro.env.medium_size}>" }
  
  # Callbacks
  before_save :set_profile_image

  def profile_image_type
    if profile_image.present?
      :upload
    elsif profile_image_url.present?
      :url
    else
      :gravatar
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name if auth.info.name
      user.email = auth.info.email if auth.info.email
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

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    # set_profile_image
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

private
  def set_profile_image
    if self.profile_image_option != "url"
      self.profile_image_url = nil
    end
    if self.profile_image_option != "upload"
      self.profile_image = nil
    end

    profile_image_option = nil
  end
end
