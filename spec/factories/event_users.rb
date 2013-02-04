FactoryGirl.define do
  factory :event_user do
    association :user
    association :event
  end
end