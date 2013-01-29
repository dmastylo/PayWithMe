FactoryGirl.define do
  factory :message do
    sequence(:message) { |n| "Message #{n}" }
    association :user
    association :event
  end
end