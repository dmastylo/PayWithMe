# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  payee_id     :integer
#  payer_id     :integer
#  amount       :float
#  paid_at      :datetime
#  desired_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  processor_id :integer
#

# Validators should be moved elsewhere

class CurrentUserValidator < ActiveModel::Validator
end

class FriendsWithCurrentUserValidator < ActiveModel::Validator
end

class Payment < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :amount, :desired_at, :paid_at, :payee_id, :payer_id, :processor_id

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payee_id, presence: true, current_user: true
  validates :payer_id, presence: true, friends_with_current_user: true

  # Relationships
  belongs_to :payee, class_name: "User"
  belongs_to :payer, class_name: "User"
  belongs_to :processor

  def is_current_user
    self.payee = current_user
  end

  def is_friends_with_current_user
    current_user.friends.contains?(payer)
  end

end
