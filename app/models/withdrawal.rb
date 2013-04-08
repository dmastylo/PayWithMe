# == Schema Information
#
# Table name: withdrawals
#
#  id                :integer          not null, primary key
#  linked_account_id :integer
#  amount_cents      :integer
#  status            :string(255)      default("new")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  transaction_id    :string(255)
#

class Withdrawal < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :amount_cents, :status, :transaction_id

  # Relationships
  belongs_to :linked_account

  monetize :amount_cents, allow_nil: true

end
