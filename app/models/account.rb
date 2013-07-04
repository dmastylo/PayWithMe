# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uri        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Account < ActiveRecord::Base

  # Validations
  validates :user_id, presence: true
  validates :uri,     presence: true

  # Relationships
  has_many :cards,    dependent: :destroy
  belongs_to :user

  # Creates an Account object from card information
  def self.new_from_card(card, user)
    buyer = Balanced::Marketplace.mine.create_buyer(card_uri: card.uri, name: user.name, email: user.email)
    account = self.new
    account.uri = buyer.uri
    return account
  end

  # Associates a card on Balanced. The card has already been created on Balanced
  def associate_card(card)
    unless self.cards.include?(card)
      remote.add_card(card.uri)
    end
  end

  # Debits the account for a certain amount
  def debit(amount)
    response = remote.debit(amount.cents)
    if response.status == "succeeded"
      return response.hold
    else
      # Handle payment failure
    end
  end

private
  # Provides a reference to the Balanced object for this account
  def remote
    Balanced::Account.find(self.uri)
  end

end