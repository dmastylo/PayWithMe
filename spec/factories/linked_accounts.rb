FactoryGirl.define do
  factory :linked_account do
    provider "twitter"
    uid "12345678"
  end
end