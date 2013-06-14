class CardsController < ApplicationController
  before_filter :authenticate_user!

  def create
    card = Card.new(params.slice(:brand, :expiration_month, :expiration_year, :uri))
    if current_user.account.present?

    else
      # Creating a new account and immeadiately associating the card
      current_user.account = Account.create_from_card(card)
    end
  end

end