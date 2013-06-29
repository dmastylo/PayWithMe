class CardsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    card = Card.new(params.slice(:brand, :expiration_month, :expiration_year, :uri))
    if current_user.account.present?
      logger.debug "Associated card for existing account for user #{current_user.id}"
      current_user.account.associate_card(card)
    else
      # Creating a new account and immeadiately associating the card
      current_user.account = Account.new_from_card(card)
      if current_user.account.save
        # Success state, the account has just been created
        logger.debug "Created account and card for user #{current_user.id}"
        current_user.account.cards << card
      else
        # Show an error response, card creation failed
      end
    end

    respond_with(card) do |format|
      format.js {render json: card, root: "card"}
    end
  end

end