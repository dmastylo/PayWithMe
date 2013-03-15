FactoryGirl.define do
  factory :linked_account do
    association :user
    provider "twitter"
    uid "12345678"
  end
end