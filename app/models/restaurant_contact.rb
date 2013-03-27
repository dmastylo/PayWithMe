# == Schema Information
#
# Table name: restraunt_contacts
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  split           :boolean          default(TRUE)
#  deal            :boolean          default(TRUE)
#  comment         :string(255)
#  name            :string(255)
#  restaurant_name :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class RestaurantContact < ActiveRecord::Base
  
  attr_accessible :comment, :deal, :email, :name, :restaurant_name, :split

  # Validations
  validates :email, presence: true
  validates :name, presence: true
  validates :restaurant_name, presence: true

end
