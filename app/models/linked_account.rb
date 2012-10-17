class LinkedAccount < ActiveRecord::Base
  
  # Accessible Attributes
  attr_accessible :provider, :token, :uid

  # Validations
  validates :provider, presence: true
  validates :token, presence: true
  validates :user_id, presence: true
  validates :uid, presence: true

  # Associations
  belongs_to :user

end