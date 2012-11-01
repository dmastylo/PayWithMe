# == Schema Information
#
# Table name: linked_accounts
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider     :string(255)
#  uid          :string(255)
#  token        :string(255)
#  user_id      :integer
#  token_secret :string(255)
#

class LinkedAccount < ActiveRecord::Base
  
  # Accessible Attributes
  # I want these to be able to be set but not by the user -- only by us
  attr_accessible :provider, :token, :uid

  # Validations
  validates :provider, presence: true
  validates :token, presence: true
  validates :user_id, presence: true
  validates :uid, presence: true

  # Associations
  belongs_to :user

end
