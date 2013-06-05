# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  per_person      :boolean          default(TRUE)
#  deal       :boolean          default(TRUE)
#  comment    :string(255)
#  name       :string(255)
#  contact    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type       :string(255)
#

class Organization < ActiveRecord::Base

	self.inheritance_column = :none

	# Accessible attributes
  attr_accessible :comment, :deal, :email, :name, :contact, :per_person

  # Validations
  validates :email, presence: true
  validates :contact, presence: true
  # validates :organization_name, presence: true
  validates :comment, length: { maximum: 250 }

end
