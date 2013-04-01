# == Schema Information
#
# Table name: linked_accounts
#
#  id           :integer          not null, primary key
#  provider     :string(255)
#  token        :string(255)
#  user_id      :integer
#  uid          :string(255)
#  token_secret :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  email        :string(255)
#

class LinkedAccount < ActiveRecord::Base
  
  # Accessible Attributes
  attr_accessible :provider, :uid

  # Validations
  validates :provider, presence: true
  # validates :token, presence: true
  validates :user_id, presence: true
  validates :uid, presence: true

  monetize :balance_cents

  # Associations
  belongs_to :user

  def update_balance
    if provider != "wepay"
      raise "LinkedAccount::update_balance is not currently defined for accounts other then WePay accounts"
    end

    gateway = Payment.wepay_gateway
    response = gateway.call('/account/balance', self.token_secret, {
      account_id: self.token
    })

    self.balance_cents = response["available_balance"].to_f * 100
    self.balanced_at = Time.now
    self.save
  end

end
