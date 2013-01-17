# == Schema Information
#
# Table name: reminder_users
#
#  id          :integer          not null, primary key
#  reminder_id :integer
#  user_id     :integer
#  sent        :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ReminderUser < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :reminder_id, :sent, :user_id

  # Validations
  validates :user_id, presence: true
  validates :reminder_id, presence: true

  # Relationships
  belongs_to :user
  belongs_to :reminder

end
