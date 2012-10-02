class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :uid, :username, :image
  # attr_accessible :title, :body

  before_validation :set_password

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    User.where(:provider => auth.provider, :uid => auth.uid).first
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
