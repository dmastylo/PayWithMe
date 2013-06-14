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

  # Creates an Account object from card information
  def self.create_from_card(card)
    buyer = Balanced::Marketplace.my_marketplace.create_buyer(card_uri: card.uri)
    raise buyer.to_yaml
  end

end