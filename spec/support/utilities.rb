include ApplicationHelper

def test_card_uri
  marketplace = Balanced::Marketplace.mine
  card = marketplace.create_card(
    card_number: "4111111111111111",
    expiration_month: "12",
    expiration_year: "2016"
  )
  card.uri
end