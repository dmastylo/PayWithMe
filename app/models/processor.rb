# == Schema Information
#
# Table name: processors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  image      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Processor < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :image, :name

  # Relationships
  has_and_belongs_to_many :payments

end
