FactoryGirl.define do
  factory :card do
    brand "Visa"
    uri "/v1/marketplaces/TEST-MP2edcOz75u0cdKsDK7FWcFG/cards/CC3sjdq0dlNP8LWBpmroxRNg"
    expiration_month 12
    expiration_year 2016
    association :account, factory: :account
  end

  factory :invalid_card, parent: :card do
    uri ""
  end
end