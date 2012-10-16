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

class Payment < ActiveRecord::Base

  # Accessible Attributes
  attr_accessible :amount, :desired_at, :paid_at, :payee_id, :payer_id, :processor_id

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :payer_id, presence: true
  validate :payee_id, presence: true

  # Relationships
  belongs_to :payee, class_name: "User"
  belongs_to :payer, class_name: "User"
  has_and_belongs_to_many :processors

  def pay!
    # Likely save some data here, like processor keys or something

    self.paid_at = Time.now
    self.save
  end

end
