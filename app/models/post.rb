# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text
#  published  :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Post < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :title, :content, :published

  # Validations
  # ========================================================
  validates :title, presence: true, length: { minimum: 2, maximum: 150, message: "has to be between 2 and 150 characters long" }, uniqueness: true
  validates :content, presence: true
  validates_inclusion_of :published, :in => [true, false]

  # Scopes
  # ========================================================
  default_scope order: 'posts.created_at DESC'
  scope :unpublished, where(published: false)
  scope :published, where(published: true)

end
