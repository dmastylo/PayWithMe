# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  split             :boolean          default(TRUE)
#  deal              :boolean          default(TRUE)
#  comment           :string(255)
#  name              :string(255)
#  organization_name :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Organization < ActiveRecord::Base

	# Accessible attributes
  attr_accessible :comment, :deal, :email, :name, :contact, :split

  # Validations
  validates :email, presence: true
  validates :name, presence: true
  # validates :organization_name, presence: true
  validates :comment, length: { maximum: 250 }

end
