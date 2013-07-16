FactoryGirl.define do
  factory :card do
    brand "Visa"
    uri "/v1/marketplaces/TEST-MP2edcOz75u0cdKsDK7FWcFG/cards/CC3sjdq0dlNP8LWBpmroxRNg"
    expiration_month 12
    expiration_year 2016
    # association :account, factory: :account
    # before(:create) do |card|
    #   marketplace = Balanced::Marketplace.mine
    #   remote_card = marketplace.create_card(
    #     card_number: "4111111111111111",
    #     expiration_month: "12",
    #     expiration_year: "2016"
    #   )
    #   card.uri = remote_card.uri
    # end
  end

  factory :live_card, parent: :card do
    uri { test_card_uri }
  end

  factory :invalid_card, parent: :card do
    uri ""
  end
end