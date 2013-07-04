FactoryGirl.define do
  factory :account do
    association :user
    uri "/v1/marketplaces/TEST-MP2edcOz75u0cdKsDK7FWcFG/accounts/AC3uxj3iMrwMBIDvbNgZ4yxO"
  end

  factory :invalid_account, parent: :account do
    uri ""
  end
end